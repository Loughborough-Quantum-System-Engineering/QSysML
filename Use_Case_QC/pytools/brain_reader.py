"""brain_reader: the minimal front-end of the M2M.

Reads ONLY what the M2M needs from brain_storm.sysml:
  - value attributes in Defs and Values  (attribute N : T = <expr>;)
  - scenario usages: calc N : UnitaryEvolution { in operation = X; in psi = Y; }
Everything else (constraint bodies, calc signatures, Utility, docs) is
NOT read: the kernel owns the algebra, and the binding table in m2m.py
owns the correspondence.

The expression sublanguage evaluated here is exactly what the model
uses (KerML Beta 1 constructor invocations): numbers, names, attribute
chains (h.columns), rect/polar/sqrt calls, + - * /, unary minus,
parenthesized sequences (a, b).
"""
import math
import re
from pathlib import Path

from kernel import Matrix, Basis, State, rect, polar, tensor_basis, tensor_basis

# feature constructors (named-argument invocation, KerML 8.4.4.9.4)
_CTORS = {
    "Vector": lambda **kw: tuple(kw["c"]),
    "Matrix": lambda **kw: Matrix(tuple(kw["columns"])),
    "UnitaryMatrix": lambda **kw: Matrix(tuple(kw["columns"])),
    "Basis": lambda **kw: Basis(kw["dimension"], tuple(kw["members"])),
    "TensorBasis": lambda **kw: tensor_basis(kw["left"], kw["right"]),
    "QuantumState": lambda **kw: State(kw["basis"], tuple(kw["coefficients"])),
}
# positional functions used by the model
_FUNCS = {"rect": rect, "polar": polar, "sqrt": math.sqrt,
          "tensorBasis": tensor_basis}
_CONSTS = {"pi": math.pi}

_VALHEAD_RE = re.compile(r"\battribute\s+(\w+)\s*:\s*([\w:]+)\s*")
_BIND_RE = re.compile(r":>>\s*(\w+)\s*=")
_SCEN_RE = re.compile(
    r"calc\s+(\w+)\s*:\s*([\w:]+)\s*\{([^}]*)\}")
_IN_RE = re.compile(r"\bin\s+(\w+)\s*=\s*([\w:]+)\s*;")


def _strip_comments(text):
    """Remove // line comments and /* */ block comments -- comment text
    must never reach the tokenizer or the def scanner."""
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.DOTALL)
    return re.sub(r"//[^\n]*", "", text)


def _pkg_spans(text):
    """[(name, decl_start, close_end)] for every package declaration in
    a (comment-stripped) file, in declaration order."""
    spans = []
    for m in re.finditer(r"\bpackage\s+(\w+)", text):
        try:
            brace = text.index("{", m.end())
        except ValueError:
            continue
        depth, i, n = 0, brace, len(text)
        while i < n:
            ch = text[i]
            if ch == "{":
                depth += 1
            elif ch == "}":
                depth -= 1
                if depth == 0:
                    break
            i += 1
        spans.append((m.group(1), m.start(), i))
    return spans


def _pkg_chain(spans, text, pos):
    """The chain of packages containing pos, outermost first --
    e.g. ('Quantum', 'A') for a member of Quantum::A."""
    chain = []
    for name, start, end in spans:
        if start <= pos <= end:
            chain.append(name)
    return tuple(chain)


def _body_of(text, pos):
    """The balanced { ... } body starting at the first '{' at/after
    pos; returns (inner_text, index_after_closing_brace)."""
    brace = text.index("{", pos)
    depth, i, n = 0, brace, len(text)
    while i < n:
        ch = text[i]
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                return text[brace + 1:i], i + 1
        i += 1
    raise ValueError("unterminated body")


def _capture_expr(text, pos):
    """The expression after '=': balanced-paren scan, stopping at ';' or
    a body-opening '{' at depth 0 (value usages may carry a doc body)."""
    depth, i, n = 0, pos, len(text)
    while i < n:
        ch = text[i]
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
        elif depth == 0 and ch in ";{":
            return text[pos:i].strip(), i
        i += 1
    return text[pos:n].strip(), n


def _tokenize(src):
    return re.findall(r"\d+\.\d+|\d+|\w+|[(),+\-*/.=:]", src)


class Reader:
    """Parsed model: value definitions (evaluated on demand, memoized)
    and scenario usages."""

    def __init__(self, paths):
        """paths: a single .sysml path or a list. The namespace merges
        across files: value definitions resolve by name wherever they
        live (quantum.sysml / QuantumComputing.sysml /
        GateOperations.sysml)."""
        if isinstance(paths, (str, Path)):
            paths = [paths]
        self.paths = [Path(p) for p in paths]
        self.file_pkg = {}      # model file -> declaring package name
        self.def_pkg = {}       # value def -> declaring package name
        self.defs = {}          # name -> expression source
        self.env = {}           # name -> kernel value
        self._stack = set()
        self._toks = []         # parser state (re-entrant: saved/restored)
        self._i = 0
        self.value_names = {}   # id(value) -> model name
        self.scenarios = []     # [{'name', 'file', 'operation', 'psi', 'completed', 'span'}]
        self._scan()

    def _scan(self):
        for p in self.paths:
            text = _strip_comments(p.read_text())
            m = re.search(r"\bpackage\s+(\w+)", text)
            self.file_pkg[str(p)] = m.group(1) if m else p.stem
            spans = _pkg_spans(text)
            # value definitions, BODY FORM:
            #   attribute N : T { :>> feature = expr; ... }
            # the :>> bindings redeclare features of the type and bind
            # their values; the ctor is derived from the short type name
            for m2 in _VALHEAD_RE.finditer(text):
                name, typ = m2.group(1), m2.group(2)
                rest = text[m2.end():].lstrip()
                if not rest.startswith("{"):
                    continue                     # declarations without bodies
                body, _ = _body_of(text, m2.end())
                bindings = {}
                for bm in _BIND_RE.finditer(body):
                    expr, _ = _capture_expr(body, bm.end())
                    bindings[bm.group(1)] = expr
                if bindings:
                    self.defs[name] = (typ, bindings)
                    self.def_pkg[name] = _pkg_chain(spans, text, m2.start())
        for p in self.paths:
            text = _strip_comments(p.read_text())
            spans = _pkg_spans(text)
            for m in _SCEN_RE.finditer(text):
                if m.group(2).split("::")[-1] != "UnitaryEvolution":
                    continue                     # only flow-kind scenarios
                body = m.group(3)
                ins = dict(_IN_RE.findall(body))
                self.scenarios.append({
                    "name": m.group(1),
                    "file": str(p),
                    "pkg": _pkg_chain(spans, text, m.start()),
                    "operation": ins.get("operation"),
                    "psi": ins.get("psi"),
                    "completed": "return" in body or "out" in body,
                    "span": m.span(),
                })

    def value(self, name):
        if name in self.env:
            return self.env[name]
        if name not in self.defs:
            raise KeyError(f"no value definition for '{name}'")
        if name in self._stack:
            raise ValueError(f"cyclic definition: {name}")
        self._stack.add(name)
        typ, payload = self.defs[name]
        try:
            if isinstance(payload, dict):
                # body form: bindings -> ctor kwargs (short type name)
                kwargs = {k: self._eval(e) for k, e in payload.items()}
                short = typ.split("::")[-1]
                v = _CTORS[short](**kwargs)
            else:
                # legacy declaration-suffix form (expression source)
                v = self._eval(payload)
        finally:
            self._stack.discard(name)
        self.env[name] = v
        self.value_names[id(v)] = name
        return v

    # ---- the expression evaluator ----

    def _eval(self, src):
        # strip comments first (both notation forms): // line comments
        # and /* */ block comments -- their text must never tokenize
        src = re.sub(r"/\*.*?\*/", "", src, flags=re.DOTALL)
        src = re.sub(r"//[^\n]*", "", src)
        toks = _tokenize(src)
        # RE-ENTRANCY: a nested self.value(...) call (e.g. a feature
        # chain like h.columns evaluating another definition) must not
        # clobber this parse's token stream -- save and restore.
        saved = (self._toks, self._i)
        self._toks, self._i = toks, 0
        try:
            return self._expr()
        finally:
            self._toks, self._i = saved

    def _peek(self):
        return self._toks[self._i] if self._i < len(self._toks) else None

    def _next(self):
        tok = self._peek()
        self._i += 1
        return tok

    def _expr(self):
        v = self._term()
        while self._peek() in ("+", "-"):
            op = self._next()
            rhs = self._term()
            v = v + rhs if op == "+" else v - rhs
        return v

    def _term(self):
        v = self._unary()
        while self._peek() in ("*", "/"):
            op = self._next()
            rhs = self._unary()
            v = v * rhs if op == "*" else v / rhs
        return v

    def _unary(self):
        if self._peek() == "-":
            self._next()
            return -self._unary()
        return self._atom()

    def _atom(self):
        tok = self._next()
        if tok is None:
            raise SyntaxError("unexpected end of expression")
        # inline namespace qualification (A::B): packages are flattened
        # in the reader, so resolve to the member name
        while (self._peek() == ":"
               and self._i + 1 < len(self._toks)
               and self._toks[self._i + 1] == ":"):
            self._next()
            self._next()
            tok = self._next()
        if re.match(r"^[\d.]", tok):
            return float(tok)
        if tok == "(":
            items = [self._expr()]
            while self._peek() == ",":
                self._next()
                items.append(self._expr())
            assert self._next() == ")", "missing ')'"
            return tuple(items) if len(items) > 1 else items[0]
        if re.match(r"^\w+$", tok):
            if self._peek() == "(":                     # invocation
                self._next()
                args = []
                if self._peek() != ")":
                    while True:
                        key = None
                        if (re.match(r"^\w+$", self._peek() or "")
                                and self._toks[self._i + 1] == "="):
                            key = self._next()
                            self._next()
                        args.append((key, self._expr()))
                        if self._peek() == ",":
                            self._next()
                            continue
                        break
                assert self._next() == ")", "missing ')'"
                return self._call(tok, args)
            chain = [tok]
            while self._peek() == ".":                  # h.columns
                self._next()
                chain.append(self._next())
            base = self.value(chain[0]) if chain[0] in self.defs \
                else _CONSTS[chain[0]]
            for attr in chain[1:]:
                base = getattr(base, attr)
            return base
        raise SyntaxError(f"unexpected token {tok!r}")

    def _call(self, name, args):
        if name in _CTORS:                              # named-argument form
            kwargs = {k: v for k, v in args if k is not None}
            return _CTORS[name](**kwargs)
        if name in _FUNCS:                              # positional form
            assert all(k is None for k, _ in args), \
                f"{name} takes positional arguments"
            return _FUNCS[name](*[v for _, v in args])
        raise KeyError(f"unknown function or type '{name}'")


def load(paths):
    """Reader + the standard derived views the M2M works with.
    paths: a single .sysml path or a list (the namespace merges)."""
    r = Reader(paths)
    values = {name: r.value(name) for name in r.defs}
    states = {n: v for n, v in values.items() if isinstance(v, State)}
    named_E = {n: __import__("kernel").frame_to_E(
        v.coefficients, v.basis.members) for n, v in states.items()}
    basis_names = {id(v.basis): r.value_names[id(v.basis)]
                   for v in states.values()}
    return r, values, states, named_E, basis_names
