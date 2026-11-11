#!/usr/bin/env python3
"""File-based ToolExecution runner v6 (decision #54): the sysml SDK as
the CORE reader, spec-shaped; value evaluation and write-back ours.

Architecture:
  READER     = sysml SDK payload backend on <model-stem>.json (the
               interchange JSON cached beside the model; unwrapped from
               the Pilot %export {payload, identity} form when needed).
               SDK provides: spec-shaped enumeration
               (elements_of_type), qualified-name resolution, analysis
               case steps, enum members. Metadata VALUES and parameter
               declarations are extracted from the raw payload nodes
               (the SDK's Feature.value is a derived property the
               payload backend does not answer - decision #48/#52b
               finding), using strict level-keyed walks that cannot
               leak across shared memberships.
  EVALUATOR  = input values are evaluated from the usage body text per
               the KerML arithmetic subset (numbers, pi, unary -,
               binary + - * / **, same-file attribute bindings).
               Expression TREES are readable via the SDK (probed:
               theta = (/ pi, 4.0) with pi resolving to
               TrigFunctions::pi) - the tree walker is banked for v7.
  WRITE-BACK = FeatureValue bindings in the usage body, full-precision
               repr, UPDATE-not-append; braceless usages gain a body.

Fallback: the textual (regex) reader for models without an interchange
JSON.

Usage: run_tools.py <model.sysml> [analysis|usage name] [--apply]
Tool root: QSYSML_TOOLS env -> tools.json -> model directory.
"""
import importlib.util
import json
import math
import os
import re
import sys
from pathlib import Path

PI = 3.141592653589793   # the 64-bit execution value of pi (KerML 9.4.13.2)


# ---- interchange loading + unwrapping ---------------------------------------

def load_interchange(model_path):
    json_path = model_path.with_suffix(".json")
    if not json_path.exists():
        return None
    raw = json.load(open(json_path))
    flat = []
    for e in raw:
        if isinstance(e, dict) and "payload" in e:
            node = dict(e["payload"])
            node.setdefault("@id", (e.get("identity") or {}).get("@id")
                            or node.get("@id") or node.get("elementId"))
            flat.append(node)
        else:
            flat.append(e)
    nodes = {n.get("@id"): n for n in flat if n.get("@id")}
    try:
        import sysml
        model = sysml.Model.from_full_json(json.loads(json.dumps(flat)),
                                           library=library_payload())
    except Exception as e:
        print(f"(interchange JSON present but SDK read failed: {e}; "
              f"falling back to textual reader)")
        return None
    return {"flat": flat, "nodes": nodes, "model": model, "path": json_path}


_LIB = None


def library_payload():
    global _LIB
    if _LIB is None:
        import sysml
        with open(sysml.standard_library_json(), encoding="utf-8") as f:
            _LIB = sysml.PayloadLibrary(json.load(f))
    return _LIB


# ---- strict raw-node walks (payload form) ------------------------------------

META_MEMBER_KEYS = ("ownedMember", "ownedMemberElement", "member",
                    "memberElement", "ownedRelatedElement", "relatedElement",
                    "target", "value", "annotatedElement")


def meta_feature_values(mu_id, nodes):
    """Strict walk from a MetadataUsage node to its feature VALUES:
    MetadataUsage -> ownedFeature -> Feature -> ownedRelationship ->
    FeatureValue -> value -> Literal* node. Returns
    {feature_name: value} - never crosses shared memberships."""
    out = {}
    mu = nodes.get(mu_id)
    if not mu:
        return out
    for fref in mu.get("ownedFeature", []) or []:
        fid = fref.get("@id") if isinstance(fref, dict) else fref
        feat = nodes.get(fid)
        if not feat:
            continue
        fname = feat.get("declaredName")
        for rref in feat.get("ownedRelationship", []) or []:
            rid = rref.get("@id") if isinstance(rref, dict) else rref
            rel = nodes.get(rid)
            if not rel or rel.get("@type") != "FeatureValue":
                continue
            vref = rel.get("value")
            vid = vref.get("@id") if isinstance(vref, dict) else vref
            lit = nodes.get(vid, {})
            if lit.get("@type", "").startswith("Literal"):
                out[fname] = lit.get("value")
    return out


# ---- textual readers (fallback + shared bindings) ----------------------------

def block_after(text, start_pat):
    m = re.search(start_pat, text)
    if not m:
        return None
    i = text.index("{", m.end())
    depth, j = 0, i
    while j < len(text):
        if text[j] == "{":
            depth += 1
        elif text[j] == "}":
            depth -= 1
            if depth == 0:
                return text[i + 1:j]
        j += 1
    return None


def regex_usages(text):
    usages = {}
    for m in re.finditer(r"(calc|action)\s+(\w+)\s*:\s*(\w+)", text):
        keyword, name, def_name = m.group(1), m.group(2), m.group(3)
        rest = text[m.end():]
        brace, semi = rest.find("{"), rest.find(";")
        has_body = brace != -1 and (semi == -1 or brace < semi)
        block = block_after(text, re.escape(m.group(0))) if has_body else ""
        usages[name] = {"definition": def_name, "keyword": keyword,
                        "in": {k: v.strip() for k, v in
                               re.findall(r"in\s+(\w+)\s*=\s*([^;]+);", block or "")},
                        "out": {k: v.strip() for k, v in
                                re.findall(r"(?:out|return)\s+(\w+)\s*=\s*([^;]+);", block or "")}}
    return usages


def regex_cases(text):
    cases, studies = {}, {}
    for m in re.finditer(r"analysis\s+def\s+(\w+)", text):
        body = block_after(text, re.escape("analysis def " + m.group(1))) or ""
        cases[m.group(1)] = re.findall(r"calc\s+(\w+)\s*:\s*(\w+)", body)
    for m in re.finditer(r"analysis\s+(\w+)\s*:\s*(\w+)", text):
        studies[m.group(1)] = m.group(2)
    return cases, studies


def regex_attribute_bindings(text):
    return {k: v.strip() for k, v in
            re.findall(r"attribute\s+(\w+)\s*(?::[^=]+)?=\s*([^;]+);", text)}


# ---- input expression evaluation (KerML arithmetic subset) ----------------

class ExprEvaluator:
    def __init__(self, bindings):
        self.bindings = bindings
        self.resolving = set()

    def evaluate(self, expr):
        self.resolving = set()
        value, rest = self._parse(self._tokens(expr.strip()))
        if rest:
            raise SyntaxError(f"trailing tokens: {rest}")
        return value

    def _tokens(self, s):
        spec = (r"\s*(\*\*|[+\-*/()]"
                r"|\d+\.\d*(?:[eE][+-]?\d+)?|\d+(?:[eE][+-]?\d+)?|\w+)")
        tokens, i = [], 0
        while i < len(s):
            m = re.match(spec, s[i:])
            if not m:
                raise SyntaxError(f"cannot tokenize at: {s[i:]!r}")
            tokens.append(m.group(1))
            i += m.end()
        return tokens

    def _parse(self, tokens):
        value, rest = self._mul(tokens)
        while rest and rest[0] in ("+", "-"):
            op, (rhs, rest) = rest[0], self._mul(rest[1:])
            value = value + rhs if op == "+" else value - rhs
        return value, rest

    def _mul(self, tokens):
        value, rest = self._unary(tokens)
        while rest and rest[0] in ("*", "/"):
            op, (rhs, rest) = rest[0], self._unary(rest[1:])
            value = value * rhs if op == "*" else value / rhs
        return value, rest

    def _unary(self, tokens):
        if tokens and tokens[0] == "-":
            value, rest = self._unary(tokens[1:])
            return -value, rest
        if tokens and tokens[0] == "+":
            return self._unary(tokens[1:])
        return self._power(tokens)

    def _power(self, tokens):
        base, rest = self._atom(tokens)
        if rest and rest[0] == "**":
            exp, rest = self._unary(rest[1:])
            return base ** exp, rest
        return base, rest

    def _atom(self, tokens):
        if not tokens:
            raise SyntaxError("unexpected end of expression")
        tok = tokens[0]
        if tok == "(":
            value, rest = self._parse(tokens[1:])
            if not rest or rest[0] != ")":
                raise SyntaxError("missing closing parenthesis")
            return value, rest[1:]
        if re.match(r"^[\d.]", tok):
            return float(tok), tokens[1:]
        if tok == "pi":
            return PI, tokens[1:]
        if re.match(r"^\w+$", tok):
            if tok in self.resolving:
                raise ValueError(f"cyclic attribute reference: {tok}")
            if tok not in self.bindings:
                raise ValueError(f"unknown reference '{tok}'")
            self.resolving.add(tok)
            value, _ = self._parse(self._tokens(self.bindings[tok].strip()))
            self.resolving.discard(tok)
            return value, tokens[1:]
        raise SyntaxError(f"unsupported token {tok!r}")


# ---- tool resolution --------------------------------------------------------

def tool_root(model_path):
    if os.environ.get("QSYSML_TOOLS"):
        root = Path(os.environ["QSYSML_TOOLS"])
        if root.exists():
            return root
    cfg = Path(__file__).parent / "tools.json"
    if cfg.exists():
        root = Path(json.load(open(cfg)).get("toolRoot", "."))
        if root.exists():
            return root
    return model_path.parent


# ---- SDK core reader ----------------------------------------------------------

def ref_ids(node, *keys):
    ids = []
    for k in keys:
        v = node.get(k)
        if isinstance(v, dict) and v.get("@id"):
            ids.append(v["@id"])
        elif isinstance(v, list):
            ids += [i.get("@id") for i in v if isinstance(i, dict) and i.get("@id")]
    return ids



def read_view_sdk(interchange):
    """Spec-shaped extraction via the SDK payload backend: enumeration by
    elements_of_type, resolution by qualified name; metadata VALUES and
    parameter declarations from the raw payload nodes (strict walks)."""
    model = interchange["model"]
    flat, nodes = interchange["flat"], interchange["nodes"]
    # the SDK elements carry elementId, matching the raw payload @id
    # (the raw %export payload has NO qualifiedName - it is derived)

    view = {"defs": {}, "usages": {}, "cases": {}, "studies": {},
            "enums": {}, "bindings": {}}

    for el in model.elements_of_type("CalculationDefinition"):
        name = getattr(el, "declaredName", "")
        node = nodes.get(getattr(el, "elementId", None) or getattr(el, "element_id", None))
        if not node:
            continue
        uri, tool_name = None, None
        for mref in node.get("ownedMetadata", []) or []:
            mid = mref.get("@id") if isinstance(mref, dict) else mref
            mu = nodes.get(mid)
            if not mu:
                continue
            for fref in mu.get("ownedFeature", []) or []:
                fid = fref.get("@id") if isinstance(fref, dict) else fref
                feat = nodes.get(fid)
                if not feat:
                    continue
                for rref in feat.get("ownedRelationship", []) or []:
                    rid = rref.get("@id") if isinstance(rref, dict) else rref
                    rel = nodes.get(rid)
                    if not rel or rel.get("@type") != "FeatureValue":
                        continue
                    vref = rel.get("value")
                    vid = vref.get("@id") if isinstance(vref, dict) else vref
                    lit = nodes.get(vid, {})
                    if lit.get("@type", "").startswith("Literal"):
                        v = lit.get("value")
                        # the payload-form features carry no declaredName:
                        # identify by value shape (uri = file#function)
                        if isinstance(v, str) and "#" in v and ".py" in v:
                            uri = v
                        elif isinstance(v, str) and v and "#" not in v \
                                and not tool_name:
                            tool_name = v
        if not uri:
            continue
        params, seen = [], set()
        for rel_ref in node.get("ownedRelationship", []) \
                + node.get("ownedMembership", []):
            rid = rel_ref.get("@id") if isinstance(rel_ref, dict) else rel_ref
            rel = nodes.get(rid)
            if not rel:
                continue
            rt = rel.get("@type")
            if rt not in ("ParameterMembership", "ReturnParameterMembership",
                          "FeatureMembership"):
                continue
            kind = "return" if rt == "ReturnParameterMembership" else None
            for pid in ref_ids(rel, "ownedMemberElement", "memberElement",
                               "ownedMember", "member"):
                p = nodes.get(pid)
                if not p:
                    continue
                pname = p.get("declaredName")
                if not pname or pname in seen:
                    continue
                direction = p.get("direction")
                if direction not in ("in", "out"):
                    continue
                seen.add(pname)
                if kind is None:
                    kind = direction
                tool_v = None
                for mk in ("nestedMetadata", "ownedMetadata"):
                    for mref in p.get(mk, []) or []:
                        mid = mref.get("@id") if isinstance(mref, dict) else mref
                        mu = nodes.get(mid)
                        if not mu:
                            continue
                        for fref in mu.get("ownedFeature", []) or []:
                            fid = fref.get("@id") if isinstance(fref, dict) else fref
                            feat = nodes.get(fid)
                            if not feat:
                                continue
                            for rref in feat.get("ownedRelationship", []) or []:
                                rid2 = rref.get("@id") if isinstance(rref, dict) else rref
                                rel2 = nodes.get(rid2)
                                if not rel2 or rel2.get("@type") != "FeatureValue":
                                    continue
                                vref = rel2.get("value")
                                vid = vref.get("@id") if isinstance(vref, dict) else vref
                                lit = nodes.get(vid, {})
                                if lit.get("@type", "").startswith("Literal") \
                                        and tool_v is None:
                                    tool_v = lit.get("value")
                type_ids = [i.get("@id") if isinstance(i, dict) else i
                            for i in p.get("type", [])]
                ptype = next((nodes[i].get("declaredName") for i in type_ids
                              if i in nodes), None)
                params.append({"kind": kind, "type": ptype,
                               "direction": direction, "name": pname,
                               "toolName": tool_v or pname})
        view["defs"][name] = {"uri": uri, "toolName": tool_name,
                              "params": params}

    for el in model.elements_of_type("CalculationUsage") \
            + model.elements_of_type("ActionUsage"):
        name = getattr(el, "declaredName", "")
        types = [getattr(t, "declaredName", None)
                 for t in (getattr(el, "type", None) or [])]
        view["usages"][name] = {"definition": next((t for t in types if t), None),
                                "keyword": "calc"
                                if type(el).__name__ == "CalculationUsage"
                                else "action", "in": {}, "out": {}}

    for el in model.elements_of_type("AnalysisCaseDefinition"):
        name = getattr(el, "declaredName", "")
        steps = []
        for f in (getattr(el, "ownedFeature", None) or []):
            t = type(f).__name__
            if "CalculationUsage" in t:
                types = [getattr(x, "declaredName", None)
                         for x in (getattr(f, "type", None) or [])]
                steps.append((getattr(f, "declaredName", ""),
                              next((x for x in types if x), None)))
        view["cases"][name] = steps

    for el in model.elements_of_type("AnalysisCaseUsage"):
        types = [getattr(t, "declaredName", None)
                 for t in (getattr(el, "type", None) or [])]
        case_name = next((t for t in types if t), None)
        if case_name:
            view["studies"][getattr(el, "declaredName", "")] = case_name

    for el in model.elements_of_type("EnumerationDefinition"):
        members = [getattr(m, "declaredName", "?")
                   for m in (getattr(el, "ownedMember", None) or [])
                   if getattr(m, "declaredName", "?") != "?"]
        view["enums"][getattr(el, "declaredName", "")] = members

    return view


# ---- write-back (kind-aware; unchanged since v2) -------------------------------

def sysml_literal(value):
    if isinstance(value, list):
        return "(" + ", ".join(sysml_literal(v) for v in value) + ")"
    if isinstance(value, str):
        return '"' + value.replace('"', '\\"') + '"'   # SysML string literal
    return repr(value)


# ---- execution ---------------------------------------------------------------

def run_binding(model_text, usage_name, usage, definition, evaluator,
                enums, root, computed, apply):
    file_part, func_name = definition["uri"].split("#")
    tool_path = root / file_part
    spec = importlib.util.spec_from_file_location("tool_" + func_name, tool_path)
    tool = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(tool)
    func = getattr(tool, func_name)

    tool_names = {p["name"]: p["toolName"] for p in definition["params"]}
    kinds = {p["name"]: p["kind"] for p in definition["params"]}
    ptypes = {p["name"]: p.get("type") for p in definition["params"]}

    kwargs = {}
    for pname, expr in usage["in"].items():
        etype = ptypes.get(pname)
        chain = re.match(r"^(\w+)\.(\w+)$", expr.strip())
        if chain and chain.group(1) in computed \
                and chain.group(2) in computed[chain.group(1)]:
            value = computed[chain.group(1)][chain.group(2)]
        elif etype in enums:
            value = expr.strip().split("::")[-1]
            if value not in enums[etype]:
                raise ValueError(f"'{value}' is not a member of {etype}")
        else:
            value = evaluator.evaluate(expr)
        kwargs[tool_names.get(pname, pname)] = value
        print(f"input    : {pname} ({tool_names.get(pname, pname)}) = {value!r}")

    results = func(**kwargs)
    print(f"results  : {results!r}")

    updated = None
    if apply:
        out_params = [p["name"] for p in definition["params"]
                      if kinds[p["name"]] in ("out", "return")]
        decl_pat = re.compile(
            r"(" + re.escape(usage["keyword"]) + r"\s+" + re.escape(usage_name) +
            r"\s*:\s*" + re.escape(usage["definition"]) + r")(\s*\{([^}]*)\})?(\s*;?)")

        def build_body(existing):
            body, written = existing or "", 0
            for pname in out_params:
                value = results[tool_names[pname]]
                kind = kinds[pname]
                etype = ptypes.get(pname)
                if etype in enums:
                    if value not in enums[etype]:
                        print(f"writeback: SKIPPED - '{value}' is not a "
                              f"member of {etype}")
                        continue
                    binding = f"{etype}::{value}"
                else:
                    binding = sysml_literal(value)
                body = re.sub(r"\s*(?:out|return)\s+" + re.escape(pname) +
                              r"\s*=\s*[^;]+;", "", body)
                body = (body.rstrip() + f" {kind} {pname} = {binding};") \
                    if body.strip() else f" {kind} {pname} = {binding};"
                written += 1
                print(f"writeback: {kind} {pname} = {value!r}")
            return body, written

        base = updated or model_text
        m = decl_pat.search(base)
        if not m:
            raise RuntimeError(f"usage declaration for '{usage_name}' not found")
        body, _ = build_body(m.group(3) or "")
        base = base[:m.start()] + m.group(1) + " {" + body + " }" \
            + (m.group(4) or "") + base[m.end():]
        updated = base
    out_values = {pname: results[tool_names[pname]]
                  for pname in tool_names
                  if kinds.get(pname) in ("out", "return")}
    return out_values, updated


def main():
    model_path = Path(sys.argv[1])
    target = None
    apply = "--apply" in sys.argv
    for a in sys.argv[2:]:
        if a == "--apply":
            apply = True
        elif not a.startswith("--"):
            target = a

    model_text = model_path.read_text()
    bindings = regex_attribute_bindings(model_text)
    usages = regex_usages(model_text)
    enums = {}
    root = tool_root(model_path)
    evaluator = ExprEvaluator(bindings)

    interchange = load_interchange(model_path)
    if interchange:
        view = read_view_sdk(interchange)
        print(f"reader   : sysml SDK payload backend "
              f"({interchange['path'].name}, {len(interchange['flat'])} nodes)")
        enums = view["enums"]
    else:
        cases, studies = regex_cases(model_text)
        view = {"defs": {}, "usages": {}, "cases": cases, "studies": studies,
                "enums": {}}
        print("reader   : textual (regex fallback)")

    defs = view["defs"]
    for name, ju in view.get("usages", {}).items():
        if name in usages and ju.get("definition"):
            usages[name]["definition"] = ju["definition"]
    for name, members in view.get("enums", {}).items():
        enums.setdefault(name, members)

    plan = []
    if target and target in view["cases"]:
        plan = [name for name, _ in view["cases"][target]]
        print(f"analysis : {target} -> {plan}")
    elif target and target in view["studies"]:
        case_name = view["studies"][target]
        plan = [name for name, _ in view["cases"].get(case_name, [])]
        print(f"analysis : {target} ({case_name}) -> {plan}")
    elif target:
        plan = [target]
    else:
        for study_name, case_name in view["studies"].items():
            if case_name in view["cases"]:
                names = [name for name, _ in view["cases"][case_name]]
                plan += names
                print(f"analysis : {study_name} ({case_name}) -> {names}")
    plan = list(dict.fromkeys(plan))
    if not plan:
        raise RuntimeError("no analysis case with bound calc usages found "
                           "(and no usage named)")

    text = model_text
    computed = {}
    for usage_name in plan:
        print(f"── {usage_name} ──")
        if usage_name not in usages:
            raise RuntimeError(f"calc/action usage '{usage_name}' not found in text")
        usage = usages[usage_name]
        definition = defs.get(usage["definition"])
        if not definition or not definition["uri"]:
            raise RuntimeError(f"definition '{usage['definition']}' has no "
                               f"ToolExecution uri in the active reader")
        out_values, text = run_binding(text, usage_name, usage, definition,
                                       evaluator, enums, root, computed, apply)
        computed[usage_name] = out_values

    if apply and text != model_text:
        model_path.write_text(text)
        print(f"written  : {model_path}")
    elif not apply:
        print("(report only; pass --apply to write back)")


if __name__ == "__main__":
    main()
