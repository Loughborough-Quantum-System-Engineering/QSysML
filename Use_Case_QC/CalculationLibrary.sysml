// QSysML calculation library, layers 0-1: scalar and complex-pair
// arithmetic (ScalarCalc), small dense matrices (LinCalc).
// Written in the subset the SysML v2 Pilot Implementation evaluates.
// Full contracts, conventions and evaluation status:
// CalculationLibrary.md (this folder).

package CalculationLibrary {
    package ScalarCalc {
        doc /* Layer 0: scalar and complex-pair arithmetic in the subset the
               SysML v2 Pilot Implementation evaluates. A complex number
               x + i y is the pair (x, y) as Real[2]: element 1 is the real
               part x, element 2 is the imaginary part y; i is never stored,
               it is dissolved into these operation rules. Spec-level
               counterpart: KerML Complex (9.4.8). Full contracts and
               conventions: CalculationLibrary.md (this folder).
               Source: Nielsen-Chuang sec 1.2, sec 4.2; Pilot 0.63.1
               evaluator notes, 2026-11. */
        private import ScalarValues::*;
        private import TrigFunctions::*;

        // ---- real scalar helpers ----------------------------------------

        calc def Abs {
            doc /* in: Real x; out: |x|. */
            in x : Real;
            return : Real = if x < 0.0 ? -x else x;
        }

        calc def Sqrt {
            doc /* in: Real x >= 0; out: sqrt(x) via ** 0.5
                   (RealFunctions::sqrt has no evaluated body). */
            in x : Real;
            return : Real = x ** 0.5;
        }

        calc def Close {
            doc /* in: Reals a, b, tolerance eps (default 1.0E-9,
                   overridable); out: |a - b| < eps. Identities are
                   asserted within tolerance, never with ==
                   (evaluation rounds ~1E-16). */
            in a : Real;
            in b : Real;
            in eps : Real default 1.0E-9;
            return : Boolean = Abs(a - b) < eps;
        }

        // ---- complex-pair arithmetic: x + i y as (x, y) -----------------

        calc def ComplexAdd {
            doc /* in: pairs a = (x, y), b = (u, v); out: (x + u, y + v). */
            in a : Real[2] ordered nonunique;
            in b : Real[2] ordered nonunique;
            return : Real[2] ordered nonunique =
                (a#(1) + b#(1), a#(2) + b#(2));
        }

        calc def ComplexSubtract {
            doc /* in: pairs a = (x, y), b = (u, v); out: (x - u, y - v). */
            in a : Real[2] ordered nonunique;
            in b : Real[2] ordered nonunique;
            return : Real[2] ordered nonunique =
                (a#(1) - b#(1), a#(2) - b#(2));
        }

        calc def ComplexScale {
            doc /* in: real c, pair a = (x, y); out: (c*x, c*y).
                   E.g. the 1/sqrt(2) factor of the Hadamard. */
            in c : Real;
            in a : Real[2] ordered nonunique;
            return : Real[2] ordered nonunique =
                (c * a#(1), c * a#(2));
        }

        calc def ComplexMultiply {
            doc /* in: pairs a = (x, y), b = (u, v);
                   out: (x*u - y*v, x*v + y*u).
                   The negative term is i^2 = -1. */
            in a : Real[2] ordered nonunique;
            in b : Real[2] ordered nonunique;
            return : Real[2] ordered nonunique =
                (a#(1)*b#(1) - a#(2)*b#(2),
                 a#(1)*b#(2) + a#(2)*b#(1));
        }

        calc def ComplexConjugate {
            doc /* in: pair a = (x, y); out: (x, -y). Building block of
                   inner products and of the conjugate transpose
                   (the dagger, layer 1). */
            in a : Real[2] ordered nonunique;
            return : Real[2] ordered nonunique =
                (a#(1), -a#(2));
        }

        calc def ComplexAbsSquared {
            doc /* in: pair a = (x, y); out: x^2 + y^2, the squared modulus.
                   The Born rule: probability = |amplitude|^2. */
            in a : Real[2] ordered nonunique;
            return : Real = a#(1)*a#(1) + a#(2)*a#(2);
        }

        calc def ComplexExpI {
            doc /* in: angle theta in radians; out: the pair
                   (cos theta, sin theta) = e^{i theta}.
                   The phase factory: T = pi/4, S = pi/2, Z = pi. */
            in theta : Real;
            return : Real[2] ordered nonunique =
                (cos(theta), sin(theta));
        }
    }

    package LinCalc {
        doc /* Layer 1: small dense matrices over real and complex entries,
               general-purpose: any matrix the user supplies flows through
               these operations, standard or user-defined. Entries are
               row-major flat sequences (convention C3); a complex entry is
               a (real part, imaginary part) pair, entries stored pair by
               pair. Matrix product order: Product(left, right) means
               "apply right first, then left". Sizes are fixed at 2x2 and
               4x4 (generic sizes need loops, which the Pilot does not
               evaluate); further sizes follow the same recipe.
               Full contracts: CalculationLibrary.md section 4. */
        private import ScalarValues::*;

        // ---- identity constants -----------------------------------------

        attribute IdentityMatrix2x2Real : Real[4] ordered nonunique =
            (1.0, 0.0, 0.0, 1.0);
        attribute IdentityMatrix2x2Complex : Real[8] ordered nonunique =
            (1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);
        attribute IdentityMatrix4x4Real : Real[16] ordered nonunique =
            (1.0, 0.0, 0.0, 0.0,
             0.0, 1.0, 0.0, 0.0,
             0.0, 0.0, 1.0, 0.0,
             0.0, 0.0, 0.0, 1.0);

        // ---- 2x2 real family --------------------------------------------

        calc def Matrix2x2Real {
            doc /* in: entries a11 a12 a21 a22 (row-major); out: Real[4]. */
            in a11 : Real;  in a12 : Real;
            in a21 : Real;  in a22 : Real;
            return : Real[4] ordered nonunique = (a11, a12, a21, a22);
        }

        calc def Matrix2x2RealEntry {
            doc /* in: matrix, 1-based row and column; out: that entry. */
            in m : Real[4] ordered nonunique;
            in row : Integer;
            in column : Integer;
            return : Real = m#((row - 1) * 2 + column);
        }

        calc def Matrix2x2RealTimesState {
            doc /* in: real matrix m, qubit state psi (two complex pairs);
                   out: m . psi as a state. Real entries scale complex
                   components componentwise. */
            in m : Real[4] ordered nonunique;
            in psi : Real[4] ordered nonunique;
            return : Real[4] ordered nonunique =
                (m#(1)*psi#(1) + m#(2)*psi#(3),
                 m#(1)*psi#(2) + m#(2)*psi#(4),
                 m#(3)*psi#(1) + m#(4)*psi#(3),
                 m#(3)*psi#(2) + m#(4)*psi#(4));
        }

        calc def Matrix2x2RealProduct {
            doc /* in: left, right (Real[4]); out: left . right.
                   Order: apply right first, then left. */
            in left : Real[4] ordered nonunique;
            in right : Real[4] ordered nonunique;
            return : Real[4] ordered nonunique =
                (left#(1)*right#(1) + left#(2)*right#(3),
                 left#(1)*right#(2) + left#(2)*right#(4),
                 left#(3)*right#(1) + left#(4)*right#(3),
                 left#(3)*right#(2) + left#(4)*right#(4));
        }

        calc def Matrix2x2RealTranspose {
            in m : Real[4] ordered nonunique;
            return : Real[4] ordered nonunique =
                (m#(1), m#(3), m#(2), m#(4));
        }

        calc def Matrix2x2RealClose {
            doc /* in: two Real[4] matrices, tolerance eps (default 1.0E-9);
                   out: true when every entry agrees within eps. */
            in left : Real[4] ordered nonunique;
            in right : Real[4] ordered nonunique;
            in eps : Real default 1.0E-9;
            return : Boolean =
                CalculationLibrary::ScalarCalc::Close(left#(1), right#(1), eps) and
                CalculationLibrary::ScalarCalc::Close(left#(2), right#(2), eps) and
                CalculationLibrary::ScalarCalc::Close(left#(3), right#(3), eps) and
                CalculationLibrary::ScalarCalc::Close(left#(4), right#(4), eps);
        }

        calc def IsUnitaryMatrix2x2Real {
            doc /* in: Real[4] matrix; out: m . transpose(m) = identity
                   within tolerance (convention C5). */
            in m : Real[4] ordered nonunique;
            return : Boolean =
                Matrix2x2RealClose(
                    Matrix2x2RealProduct(m, Matrix2x2RealTranspose(m)),
                    IdentityMatrix2x2Real);
        }

        // ---- the real-to-complex bridge ----------------------------------

        calc def Matrix2x2RealAsComplex {
            doc /* in: Real[4] matrix; out: the same matrix as Real[8],
                   zero imaginary part on every entry. Mixed products
                   (e.g. H . T^4 . H) route through the complex family. */
            in m : Real[4] ordered nonunique;
            return : Real[8] ordered nonunique =
                (m#(1), 0.0, m#(2), 0.0, m#(3), 0.0, m#(4), 0.0);
        }

        // ---- 2x2 complex family (entries are (real part, imaginary
        //      part) pairs; positions: (1,1)=1-2 (1,2)=3-4 (2,1)=5-6
        //      (2,2)=7-8) -------------------------------------------------

        calc def Matrix2x2Complex {
            doc /* in: four pairs a11, a12, a21, a22 (Real[2] each);
                   out: Real[8], pair per entry, row-major. */
            in a11 : Real[2] ordered nonunique;
            in a12 : Real[2] ordered nonunique;
            in a21 : Real[2] ordered nonunique;
            in a22 : Real[2] ordered nonunique;
            return : Real[8] ordered nonunique =
                (a11#(1), a11#(2), a12#(1), a12#(2),
                 a21#(1), a21#(2), a22#(1), a22#(2));
        }

        calc def Matrix2x2ComplexEntry {
            in m : Real[8] ordered nonunique;
            in row : Integer;
            in column : Integer;
            return : Real[2] ordered nonunique =
                (m#(2*((row - 1)*2 + column) - 1),
                 m#(2*((row - 1)*2 + column)));
        }

        calc def Matrix2x2ComplexTimesState {
            doc /* in: complex matrix m, qubit state psi; out: m . psi.
                   Each term is one ComplexMultiply expanded to real
                   arithmetic. */
            in m : Real[8] ordered nonunique;
            in psi : Real[4] ordered nonunique;
            return : Real[4] ordered nonunique =
                (m#(1)*psi#(1) - m#(2)*psi#(2) + m#(3)*psi#(3) - m#(4)*psi#(4),
                 m#(1)*psi#(2) + m#(2)*psi#(1) + m#(3)*psi#(4) + m#(4)*psi#(3),
                 m#(5)*psi#(1) - m#(6)*psi#(2) + m#(7)*psi#(3) - m#(8)*psi#(4),
                 m#(5)*psi#(2) + m#(6)*psi#(1) + m#(7)*psi#(4) + m#(8)*psi#(3));
        }

        calc def Matrix2x2ComplexProduct {
            doc /* in: left, right (Real[8]); out: left . right (Real[8]).
                   Order: apply right first, then left. */
            in left : Real[8] ordered nonunique;
            in right : Real[8] ordered nonunique;
            return : Real[8] ordered nonunique =
                (left#(1)*right#(1) - left#(2)*right#(2)
                     + left#(3)*right#(5) - left#(4)*right#(6),
                 left#(1)*right#(2) + left#(2)*right#(1)
                     + left#(3)*right#(6) + left#(4)*right#(5),
                 left#(1)*right#(3) - left#(2)*right#(4)
                     + left#(3)*right#(7) - left#(4)*right#(8),
                 left#(1)*right#(4) + left#(2)*right#(3)
                     + left#(3)*right#(8) + left#(4)*right#(7),
                 left#(5)*right#(1) - left#(6)*right#(2)
                     + left#(7)*right#(5) - left#(8)*right#(6),
                 left#(5)*right#(2) + left#(6)*right#(1)
                     + left#(7)*right#(6) + left#(8)*right#(5),
                 left#(5)*right#(3) - left#(6)*right#(4)
                     + left#(7)*right#(7) - left#(8)*right#(8),
                 left#(5)*right#(4) + left#(6)*right#(3)
                     + left#(7)*right#(8) + left#(8)*right#(7));
        }

        calc def Matrix2x2ComplexConjugateTranspose {
            doc /* in: Real[8]; out: the dagger: entry (r, c) becomes the
                   conjugate of entry (c, r). */
            in m : Real[8] ordered nonunique;
            return : Real[8] ordered nonunique =
                (m#(1), -m#(2),
                 m#(5), -m#(6),
                 m#(3), -m#(4),
                 m#(7), -m#(8));
        }

        calc def Matrix2x2ComplexScaledBy {
            doc /* in: complex scalar s = (s1, s2), matrix m (Real[8]);
                   out: s . m, every entry multiplied by s. Global phase
                   of an operator; e.g. Y = i . (X . Z) at matrix level. */
            in s : Real[2] ordered nonunique;
            in m : Real[8] ordered nonunique;
            return : Real[8] ordered nonunique =
                (s#(1)*m#(1) - s#(2)*m#(2), s#(1)*m#(2) + s#(2)*m#(1),
                 s#(1)*m#(3) - s#(2)*m#(4), s#(1)*m#(4) + s#(2)*m#(3),
                 s#(1)*m#(5) - s#(2)*m#(6), s#(1)*m#(6) + s#(2)*m#(5),
                 s#(1)*m#(7) - s#(2)*m#(8), s#(1)*m#(8) + s#(2)*m#(7));
        }

        calc def Matrix2x2ComplexClose {
            in left : Real[8] ordered nonunique;
            in right : Real[8] ordered nonunique;
            in eps : Real default 1.0E-9;
            return : Boolean =
                CalculationLibrary::ScalarCalc::Close(left#(1), right#(1), eps) and
                CalculationLibrary::ScalarCalc::Close(left#(2), right#(2), eps) and
                CalculationLibrary::ScalarCalc::Close(left#(3), right#(3), eps) and
                CalculationLibrary::ScalarCalc::Close(left#(4), right#(4), eps) and
                CalculationLibrary::ScalarCalc::Close(left#(5), right#(5), eps) and
                CalculationLibrary::ScalarCalc::Close(left#(6), right#(6), eps) and
                CalculationLibrary::ScalarCalc::Close(left#(7), right#(7), eps) and
                CalculationLibrary::ScalarCalc::Close(left#(8), right#(8), eps);
        }

        calc def IsUnitaryMatrix2x2Complex {
            doc /* in: Real[8] matrix; out: m . dagger(m) = identity
                   within tolerance (convention C5). */
            in m : Real[8] ordered nonunique;
            return : Boolean =
                Matrix2x2ComplexClose(
                    Matrix2x2ComplexProduct(m,
                        Matrix2x2ComplexConjugateTranspose(m)),
                    IdentityMatrix2x2Complex);
        }

        // ---- tensor product of states ------------------------------------

        calc def TensorProduct {
            doc /* in: two qubit states a, b (Real[4] each); out: the
                   composite state a (x) b (Real[8]), member order |00>,
                   |01>, |10>, |11> with a as the first qubit. Each member
                   amplitude is one ComplexMultiply of the member
                   amplitudes of a and b. */
            in a : Real[4] ordered nonunique;
            in b : Real[4] ordered nonunique;
            return : Real[8] ordered nonunique =
                (a#(1)*b#(1) - a#(2)*b#(2),
                 a#(1)*b#(2) + a#(2)*b#(1),
                 a#(1)*b#(3) - a#(2)*b#(4),
                 a#(1)*b#(4) + a#(2)*b#(3),
                 a#(3)*b#(1) - a#(4)*b#(2),
                 a#(3)*b#(2) + a#(4)*b#(1),
                 a#(3)*b#(3) - a#(4)*b#(4),
                 a#(3)*b#(4) + a#(4)*b#(3));
        }

        // ---- 4x4 real family ----------------------------------------------

        calc def Matrix4x4Real {
            doc /* in: sixteen entries a11 ... a44 (row-major);
                   out: Real[16]. */
            in a11 : Real; in a12 : Real; in a13 : Real; in a14 : Real;
            in a21 : Real; in a22 : Real; in a23 : Real; in a24 : Real;
            in a31 : Real; in a32 : Real; in a33 : Real; in a34 : Real;
            in a41 : Real; in a42 : Real; in a43 : Real; in a44 : Real;
            return : Real[16] ordered nonunique =
                (a11, a12, a13, a14,
                 a21, a22, a23, a24,
                 a31, a32, a33, a34,
                 a41, a42, a43, a44);
        }

        calc def Matrix4x4RealEntry {
            in m : Real[16] ordered nonunique;
            in row : Integer;
            in column : Integer;
            return : Real = m#((row - 1) * 4 + column);
        }

        calc def Matrix4x4RealTimesState {
            doc /* in: real 4x4 matrix m, two-qubit state psi (Real[8]);
                   out: m . psi as a two-qubit state. */
            in m : Real[16] ordered nonunique;
            in psi : Real[8] ordered nonunique;
            return : Real[8] ordered nonunique =
                (m#(1)*psi#(1) + m#(2)*psi#(3) + m#(3)*psi#(5) + m#(4)*psi#(7),
                 m#(1)*psi#(2) + m#(2)*psi#(4) + m#(3)*psi#(6) + m#(4)*psi#(8),
                 m#(5)*psi#(1) + m#(6)*psi#(3) + m#(7)*psi#(5) + m#(8)*psi#(7),
                 m#(5)*psi#(2) + m#(6)*psi#(4) + m#(7)*psi#(6) + m#(8)*psi#(8),
                 m#(9)*psi#(1) + m#(10)*psi#(3) + m#(11)*psi#(5) + m#(12)*psi#(7),
                 m#(9)*psi#(2) + m#(10)*psi#(4) + m#(11)*psi#(6) + m#(12)*psi#(8),
                 m#(13)*psi#(1) + m#(14)*psi#(3) + m#(15)*psi#(5) + m#(16)*psi#(7),
                 m#(13)*psi#(2) + m#(14)*psi#(4) + m#(15)*psi#(6) + m#(16)*psi#(8));
        }

        calc def Matrix4x4RealProduct {
            doc /* in: left, right (Real[16]); out: left . right.
                   Order: apply right first, then left. */
            in left : Real[16] ordered nonunique;
            in right : Real[16] ordered nonunique;
            return : Real[16] ordered nonunique =
                (left#(1)*right#(1) + left#(2)*right#(5) + left#(3)*right#(9) + left#(4)*right#(13),
                 left#(1)*right#(2) + left#(2)*right#(6) + left#(3)*right#(10) + left#(4)*right#(14),
                 left#(1)*right#(3) + left#(2)*right#(7) + left#(3)*right#(11) + left#(4)*right#(15),
                 left#(1)*right#(4) + left#(2)*right#(8) + left#(3)*right#(12) + left#(4)*right#(16),
                 left#(5)*right#(1) + left#(6)*right#(5) + left#(7)*right#(9) + left#(8)*right#(13),
                 left#(5)*right#(2) + left#(6)*right#(6) + left#(7)*right#(10) + left#(8)*right#(14),
                 left#(5)*right#(3) + left#(6)*right#(7) + left#(7)*right#(11) + left#(8)*right#(15),
                 left#(5)*right#(4) + left#(6)*right#(8) + left#(7)*right#(12) + left#(8)*right#(16),
                 left#(9)*right#(1) + left#(10)*right#(5) + left#(11)*right#(9) + left#(12)*right#(13),
                 left#(9)*right#(2) + left#(10)*right#(6) + left#(11)*right#(10) + left#(12)*right#(14),
                 left#(9)*right#(3) + left#(10)*right#(7) + left#(11)*right#(11) + left#(12)*right#(15),
                 left#(9)*right#(4) + left#(10)*right#(8) + left#(11)*right#(12) + left#(12)*right#(16),
                 left#(13)*right#(1) + left#(14)*right#(5) + left#(15)*right#(9) + left#(16)*right#(13),
                 left#(13)*right#(2) + left#(14)*right#(6) + left#(15)*right#(10) + left#(16)*right#(14),
                 left#(13)*right#(3) + left#(14)*right#(7) + left#(15)*right#(11) + left#(16)*right#(15),
                 left#(13)*right#(4) + left#(14)*right#(8) + left#(15)*right#(12) + left#(16)*right#(16));
        }

        calc def Matrix4x4RealTranspose {
            in m : Real[16] ordered nonunique;
            return : Real[16] ordered nonunique =
                (m#(1), m#(5), m#(9), m#(13),
                 m#(2), m#(6), m#(10), m#(14),
                 m#(3), m#(7), m#(11), m#(15),
                 m#(4), m#(8), m#(12), m#(16));
        }

        calc def Matrix4x4RealClose {
            in left : Real[16] ordered nonunique;
            in right : Real[16] ordered nonunique;
            in eps : Real default 1.0E-9;
            return : Boolean =
                CalculationLibrary::ScalarCalc::Close(left#(1), right#(1), eps) and
                CalculationLibrary::ScalarCalc::Close(left#(2), right#(2), eps) and
                CalculationLibrary::ScalarCalc::Close(left#(3), right#(3), eps) and
                CalculationLibrary::ScalarCalc::Close(left#(4), right#(4), eps) and
                CalculationLibrary::ScalarCalc::Close(left#(5), right#(5), eps) and
                CalculationLibrary::ScalarCalc::Close(left#(6), right#(6), eps) and
                CalculationLibrary::ScalarCalc::Close(left#(7), right#(7), eps) and
                CalculationLibrary::ScalarCalc::Close(left#(8), right#(8), eps) and
                CalculationLibrary::ScalarCalc::Close(left#(9), right#(9), eps) and
                CalculationLibrary::ScalarCalc::Close(left#(10), right#(10), eps) and
                CalculationLibrary::ScalarCalc::Close(left#(11), right#(11), eps) and
                CalculationLibrary::ScalarCalc::Close(left#(12), right#(12), eps) and
                CalculationLibrary::ScalarCalc::Close(left#(13), right#(13), eps) and
                CalculationLibrary::ScalarCalc::Close(left#(14), right#(14), eps) and
                CalculationLibrary::ScalarCalc::Close(left#(15), right#(15), eps) and
                CalculationLibrary::ScalarCalc::Close(left#(16), right#(16), eps);
        }

        calc def IsUnitaryMatrix4x4Real {
            doc /* in: Real[16] matrix; out: m . transpose(m) = identity
                   within tolerance (convention C5). */
            in m : Real[16] ordered nonunique;
            return : Boolean =
                Matrix4x4RealClose(
                    Matrix4x4RealProduct(m, Matrix4x4RealTranspose(m)),
                    IdentityMatrix4x4Real);
        }
    }

    package QuantumStateCalc {
        doc /* Layer 2: the qubit-state shape vocabulary and the bridge
               between the amplitude layer and the native description of
               quantum.sysml (Born probabilities and relative phase per
               basis member). States are Real[4] (one qubit) and Real[8]
               (two qubits); complex values are (real part, imaginary
               part) pairs (convention C1); constants use the nested
               authoring style (convention C8).
               Source: Nielsen-Chuang sec 1.2; Pilot 0.63.1 evaluator
               notes, 2026-11. */
        private import ScalarValues::*;
        private import TrigFunctions::*;

        // ---- shape vocabulary -------------------------------------------

        calc def QubitState {
            doc /* in: two complex pairs alpha, beta; out: the qubit state
                   (real part of alpha, imaginary part of alpha, real part
                   of beta, imaginary part of beta). */
            in alpha : Real[2] ordered nonunique;
            in beta : Real[2] ordered nonunique;
            return : Real[4] ordered nonunique =
                (alpha#(1), alpha#(2), beta#(1), beta#(2));
        }

        calc def QubitAlpha {
            doc /* in: qubit state psi; out: the (real part, imaginary
                   part) pair of the amplitude of member 1. */
            in psi : Real[4] ordered nonunique;
            return : Real[2] ordered nonunique = (psi#(1), psi#(2));
        }

        calc def QubitBeta {
            doc /* in: qubit state psi; out: the (real part, imaginary
                   part) pair of the amplitude of member 2. */
            in psi : Real[4] ordered nonunique;
            return : Real[2] ordered nonunique = (psi#(3), psi#(4));
        }

        // ---- basis-state constants (nested style, convention C8) --------

        attribute invSqrt2 : Real = 1.0 / CalculationLibrary::ScalarCalc::Sqrt(2.0);

        attribute Ket0 : Real[4] ordered nonunique =
            ((1.0, 0.0), (0.0, 0.0));
        attribute Ket1 : Real[4] ordered nonunique =
            ((0.0, 0.0), (1.0, 0.0));
        attribute KetPlus : Real[4] ordered nonunique =
            ((invSqrt2, 0.0), (invSqrt2, 0.0));
        attribute KetMinus : Real[4] ordered nonunique =
            ((invSqrt2, 0.0), (-invSqrt2, 0.0));

        // ---- bridge to the (probability, relativePhase) description -----

        calc def BornProbabilities {
            doc /* in: qubit state psi; out: (P(0), P(1)) - the Born
                   probabilities, the squared modulus of each basis
                   member's amplitude. Matches the probability feature of
                   Quantum::QuantumState by index. */
            in psi : Real[4] ordered nonunique;
            return : Real[2] ordered nonunique =
                (psi#(1)*psi#(1) + psi#(2)*psi#(2),
                 psi#(3)*psi#(3) + psi#(4)*psi#(4));
        }

        calc def BornProbabilitiesTwoQubit {
            doc /* in: two-qubit state psi (Real[8]); out: four Born
                   probabilities, one per register member |00>..|11>. */
            in psi : Real[8] ordered nonunique;
            return : Real[4] ordered nonunique =
                (psi#(1)*psi#(1) + psi#(2)*psi#(2),
                 psi#(3)*psi#(3) + psi#(4)*psi#(4),
                 psi#(5)*psi#(5) + psi#(6)*psi#(6),
                 psi#(7)*psi#(7) + psi#(8)*psi#(8));
        }

        calc def ToAmplitudes {
            doc /* in: Born probabilities p = (P(0), P(1)) and the relative
                   phase phi in radians (the phase of member 2 relative to
                   member 1, as in Quantum::QuantumState); out: the state
                   with alpha = sqrt(P(0)) and beta = sqrt(P(1)) e^{i phi}.
                   The bridge from the native description to the amplitude
                   layer. */
            in p : Real[2] ordered nonunique;
            in phi : Real;
            return : Real[4] ordered nonunique =
                (CalculationLibrary::ScalarCalc::Sqrt(p#(1)), 0.0,
                 CalculationLibrary::ScalarCalc::Sqrt(p#(2))*cos(phi), CalculationLibrary::ScalarCalc::Sqrt(p#(2))*sin(phi));
        }

        calc def CosRelativePhase {
            doc /* in: qubit state psi; out: the cosine of the relative
                   phase of member 2 relative to member 1: the normalized
                   inner product of the two amplitude pairs. Meaningful
                   only when both Born probabilities are nonzero - a basis
                   state's relative phase is degenerate (division by zero
                   here). */
            in psi : Real[4] ordered nonunique;
            return : Real =
                (psi#(1)*psi#(3) + psi#(2)*psi#(4)) /
                CalculationLibrary::ScalarCalc::Sqrt((psi#(1)*psi#(1) + psi#(2)*psi#(2)) *
                     (psi#(3)*psi#(3) + psi#(4)*psi#(4)));
        }

        calc def TimesI {
            doc /* in: qubit state psi; out: the state multiplied by i -
                   a global phase rotation (convention C6). States
                   identities involving global phase exactly, e.g.
                   Y = i . (X . Z) at matrix level. */
            in psi : Real[4] ordered nonunique;
            return : Real[4] ordered nonunique =
                (-psi#(2), psi#(1), -psi#(4), psi#(3));
        }

        // ---- checks (convention C5: tolerance, never ==) ----------------

        calc def IsNormalised {
            doc /* in: qubit state psi, tolerance eps (default 1.0E-9);
                   out: true when the Born probabilities sum to 1 within
                   eps. */
            in psi : Real[4] ordered nonunique;
            in eps : Real default 1.0E-9;
            return : Boolean =
                CalculationLibrary::ScalarCalc::Close(psi#(1)*psi#(1) + psi#(2)*psi#(2) +
                      psi#(3)*psi#(3) + psi#(4)*psi#(4), 1.0, eps);
        }

        calc def IsNormalisedTwoQubit {
            in psi : Real[8] ordered nonunique;
            in eps : Real default 1.0E-9;
            return : Boolean =
                CalculationLibrary::ScalarCalc::Close(psi#(1)*psi#(1) + psi#(2)*psi#(2) +
                      psi#(3)*psi#(3) + psi#(4)*psi#(4) +
                      psi#(5)*psi#(5) + psi#(6)*psi#(6) +
                      psi#(7)*psi#(7) + psi#(8)*psi#(8), 1.0, eps);
        }

        calc def StatesClose {
            doc /* in: two qubit states, tolerance eps; out: true when the
                   states agree component by component within eps. */
            in u : Real[4] ordered nonunique;
            in w : Real[4] ordered nonunique;
            in eps : Real default 1.0E-9;
            return : Boolean =
                CalculationLibrary::ScalarCalc::Close(u#(1), w#(1), eps) and CalculationLibrary::ScalarCalc::Close(u#(2), w#(2), eps) and
                CalculationLibrary::ScalarCalc::Close(u#(3), w#(3), eps) and CalculationLibrary::ScalarCalc::Close(u#(4), w#(4), eps);
        }

        calc def StatesCloseTwoQubit {
            in u : Real[8] ordered nonunique;
            in w : Real[8] ordered nonunique;
            in eps : Real default 1.0E-9;
            return : Boolean =
                CalculationLibrary::ScalarCalc::Close(u#(1), w#(1), eps) and CalculationLibrary::ScalarCalc::Close(u#(2), w#(2), eps) and
                CalculationLibrary::ScalarCalc::Close(u#(3), w#(3), eps) and CalculationLibrary::ScalarCalc::Close(u#(4), w#(4), eps) and
                CalculationLibrary::ScalarCalc::Close(u#(5), w#(5), eps) and CalculationLibrary::ScalarCalc::Close(u#(6), w#(6), eps) and
                CalculationLibrary::ScalarCalc::Close(u#(7), w#(7), eps) and CalculationLibrary::ScalarCalc::Close(u#(8), w#(8), eps);
        }

        calc def ProbabilitiesClose {
            doc /* in: two Born probability pairs, tolerance eps; out: true
                   when they agree component by component within eps. */
            in p : Real[2] ordered nonunique;
            in q : Real[2] ordered nonunique;
            in eps : Real default 1.0E-9;
            return : Boolean =
                CalculationLibrary::ScalarCalc::Close(p#(1), q#(1), eps) and CalculationLibrary::ScalarCalc::Close(p#(2), q#(2), eps);
        }
    }
}
