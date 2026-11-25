"""Closed-form and numerical equilibria for Ide & Talamas (2025), uniform knowledge.

Assumptions: G uniform on [0,1], helping cost h < h0 (no pre-AI independent producers),
compute abundant. Pure standard library: no numpy/scipy needed.

Usage:  python3 code/equilibrium.py [h]
"""

import sys

# --------------------------------------------------------------------------- #
# Small numerical helpers (no third-party dependencies)
# --------------------------------------------------------------------------- #


def newton(f, x0, tol=1e-12, max_iter=200):
    """Solve f(x) = 0 (vector valued) by Newton's method with numeric Jacobian."""
    x = list(x0)
    n = len(x)
    for _ in range(max_iter):
        fx = f(x)
        if max(abs(v) for v in fx) < tol:
            return x
        jac = []
        for i in range(n):
            step = 1e-7 * max(1.0, abs(x[i]))
            xp = list(x)
            xp[i] += step
            fp = f(xp)
            jac.append([(fp[k] - fx[k]) / step for k in range(n)])
        # jac is stored column-wise; transpose to rows
        rows = [[jac[j][i] for j in range(n)] for i in range(n)]
        delta = solve_linear(rows, [-v for v in fx])
        x = [x[i] + delta[i] for i in range(n)]
    raise RuntimeError("Newton did not converge")


def solve_linear(a, b):
    """Gaussian elimination with partial pivoting."""
    n = len(b)
    m = [row[:] + [b[i]] for i, row in enumerate(a)]
    for col in range(n):
        piv = max(range(col, n), key=lambda r: abs(m[r][col]))
        m[col], m[piv] = m[piv], m[col]
        for r in range(col + 1, n):
            factor = m[r][col] / m[col][col]
            for c in range(col, n + 1):
                m[r][c] -= factor * m[col][c]
    x = [0.0] * n
    for r in reversed(range(n)):
        x[r] = (m[r][n] - sum(m[r][c] * x[c] for c in range(r + 1, n))) / m[r][r]
    return x


def bisect(f, lo, hi, tol=1e-12):
    flo = f(lo)
    for _ in range(200):
        mid = 0.5 * (lo + hi)
        fmid = f(mid)
        if (flo < 0) == (fmid < 0):
            lo, flo = mid, fmid
        else:
            hi = mid
        if hi - lo < tol:
            break
    return 0.5 * (lo + hi)


# --------------------------------------------------------------------------- #
# Pre-AI equilibrium (Proposition 1)
# --------------------------------------------------------------------------- #


def n_of(z, h):
    """Span of control: number of workers of knowledge z a solver can supervise."""
    return 1.0 / (h * (1.0 - z))


def pre_ai(h):
    """Return (z_tilde, C, wage) for the pre-AI equilibrium with uniform G."""
    # z_tilde solves z + h (z - z^2 / 2) = 1
    z_tilde = bisect(lambda z: z + h * (z - z * z / 2) - 1.0, 0.0, 1.0)
    c = (1.0 - z_tilde * h * (1.0 - z_tilde)) / (1.0 + h * (1.0 - z_tilde))

    def m(z):
        return z_tilde + h * (z - z * z / 2)

    def wage(z):
        if z <= z_tilde:                       # workers
            return m(z) - (c + z) * h * (1.0 - z)
        return _solver_wage(z, z_tilde, c, h)   # solvers

    return z_tilde, c, wage, m


def _solver_wage(s, z_tilde, c, h):
    """w(s) for s in S, using w(m(z)) = C + z and inverting m."""
    z = bisect(lambda z: z_tilde + h * (z - z * z / 2) - s, 0.0, 1.0)
    return c + z


# --------------------------------------------------------------------------- #
# Post-AI equilibrium with an autonomous AI (Proposition 2)
# --------------------------------------------------------------------------- #


def post_ai_config_a(h, z_ai, guess=(0.3, 0.5, 0.8)):
    """AI used as worker and independent producer only (Wa* empty).

    Human sets: Wp* = [0, z1], I* = [z1, z2], Sp* = [z2, z3], Sa* = [z3, 1].
    """

    def system(v):
        z1, z2, z3 = v
        m = lambda z: z2 + h * (z - z * z / 2)
        w_worker = lambda z: m(z) - (z2 + z) * h * (1.0 - z)
        return [
            w_worker(z1) - z1,                                  # continuity with 45 degrees
            m(z1) - z3,                                         # best human worker <-> top of Sp*
            (z2 + z1) - n_of(z_ai, h) * (z3 - z_ai),            # continuity at z3
        ]

    z1, z2, z3 = newton(system, guess)
    ok = 0.0 <= z1 <= z2 <= z3 <= 1.0 and z1 <= z_ai <= z2
    return {"z1": z1, "z2": z2, "z3": z3, "w_bottom": z2 * (1.0 - h), "feasible": ok}


def z_switch(h):
    """Largest z_AI for which config A (AI not used as a solver) is still consistent.

    Config A requires z1 <= z2 (a non-degenerate set of human independent producers).
    Above this threshold the AI is also used as a solver, the least knowledgeable humans
    are supervised by AI, and w*(0) follows the closed form z_AI (1 - h).
    """
    gap = lambda z_ai: (lambda sol: sol["z2"] - sol["z1"])(
        post_ai_config_a(h, z_ai, (z_ai, min(0.999, z_ai + 0.1), min(0.999, z_ai + 0.2))))
    return bisect(gap, 0.05, 0.99)


def post_ai(h, z_ai):
    """Bottom and top wages of the autonomous-AI equilibrium.

    Below z_switch the AI is a worker but not a solver, and the bottom wage comes from the
    human matching problem. Above it the AI supervises the least knowledgeable humans, whose
    wage is pinned by the zero-profit condition of top-automated firms (Proposition 2).
    """
    if z_ai < z_switch(h):
        sol = post_ai_config_a(h, z_ai, (z_ai, min(0.999, z_ai + 0.1), min(0.999, z_ai + 0.2)))
        return "AI as worker only", {**sol, "w_bottom": sol["z2"] * (1.0 - h)}
    return "AI also as solver", {"w_bottom": z_ai * (1.0 - h)}


def wage_top_autonomous(h, z_ai):
    """w*(1) = n(z_AI) (1 - z_AI) = 1 / h, independent of z_AI."""
    return n_of(z_ai, h) * (1.0 - z_ai)


# --------------------------------------------------------------------------- #
# Non-autonomous AI (Proposition 6)
# --------------------------------------------------------------------------- #


def wage_bottom_non_autonomous(h, z_ai, w_pre_bottom):
    """With r = 0, a firm with an AI solver pays w = z_AI; AI is used iff z_AI > w(0)."""
    return max(z_ai, w_pre_bottom) if z_ai > w_pre_bottom else w_pre_bottom


# --------------------------------------------------------------------------- #
# Report
# --------------------------------------------------------------------------- #


def main(h=0.5):
    z_tilde, c, wage, m = pre_ai(h)
    w0, w1 = wage(0.0), wage(1.0)
    print(f"h = {h}")
    print(f"pre-AI:  z~ = {z_tilde:.6f}   C = {c:.6f}   w(0) = {w0:.6f}   w(1) = {w1:.6f}")

    z_bar_autonomous = w0 / (1.0 - h)          # z_AI (1 - h) = w(0)
    z_bar_non_auto = w0                        # z_AI = w(0)
    print(f"thresholds for winners at the bottom:")
    print(f"  autonomous AI      z_bar = w(0) / (1 - h) = {z_bar_autonomous:.6f}"
          f"   (in int W = (0, {z_tilde:.4f})? {z_bar_autonomous < z_tilde})")
    print(f"  non-autonomous AI  z_bar = w(0)           = {z_bar_non_auto:.6f}")

    print(f"AI starts being used as a solver at z_AI = {z_switch(h):.6f}")
    print("\n z_AI | configuration            |  w*(0)   |  w*(1)   |  w_na(0) | bottom wins?")
    for z_ai in [0.2, 0.425, 0.5, 0.6, 0.7, 0.72, 0.764, 0.85, 0.95]:
        label, sol = post_ai(h, z_ai)
        w_star_0 = sol["w_bottom"]
        w_na_0 = wage_bottom_non_autonomous(h, z_ai, w0)
        flag = "yes" if w_star_0 > w0 else "no"
        print(f" {z_ai:4.3f} | {label:24s} | {w_star_0:8.4f} | "
              f"{wage_top_autonomous(h, z_ai):8.4f} | {w_na_0:8.4f} | {flag}")


if __name__ == "__main__":
    main(float(sys.argv[1]) if len(sys.argv) > 1 else 0.5)
