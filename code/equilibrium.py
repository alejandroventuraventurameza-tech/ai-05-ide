"""Uniform-G endpoint calculations, not a full post-AI equilibrium solver.

Source: Ide & Talamas (2025), arXiv v11, Props. 1, 2 and 6.
Scope: abundant compute, 0 < h < 3/4, 0 <= AI knowledge < 1.
"""
import math
import sys

SWITCH = 2/3


def validate_h(h):
    if not math.isfinite(h) or not 0 < h < 0.75:
        raise ValueError('uniform benchmark requires 0 < h < 3/4')


def validate_ai(a):
    if not math.isfinite(a) or not 0 <= a < 1:
        raise ValueError('AI knowledge must lie in [0, 1)')


def bisect(f, lo, hi, tol=1e-12):
    flo, fhi = f(lo), f(hi)
    if not (math.isfinite(flo) and math.isfinite(fhi)):
        raise ValueError('non-finite bracket')
    if flo == 0:
        return lo
    if fhi == 0:
        return hi
    if (flo < 0) == (fhi < 0):
        raise ValueError('root not bracketed')
    while hi-lo > tol:
        mid = (lo+hi)/2
        fm = f(mid)
        if not math.isfinite(fm):
            raise ArithmeticError('non-finite residual')
        if fm == 0:
            return mid
        if (flo < 0) == (fm < 0):
            lo, flo = mid, fm
        else:
            hi = mid
    return (lo+hi)/2


def n_of(z, h):
    validate_h(h)
    validate_ai(z)
    return 1/(h*(1-z))


def pre_ai(h):
    """Pre-AI equilibrium for uniform G and no independent producers."""
    validate_h(h)
    t = 2/(1+h+math.sqrt(1+h*h))
    c = (1-t*h*(1-t))/(1+h*(1-t))

    def m(z):
        if not 0 <= z <= t:
            raise ValueError('matching defined only for pre-AI workers')
        return t+h*(z-z*z/2)

    def wage(z):
        if not 0 <= z <= 1:
            raise ValueError('human knowledge outside [0, 1]')
        if z <= t:
            return m(z)-(c+z)*h*(1-z)
        q = (z-t)/h
        worker = 2*q/(1+math.sqrt(max(0, 1-2*q)))
        return c+worker

    return t, c, wage, m


def post_ai_config_a(h, z_ai):
    """Candidate with AI workers but no AI solvers; equations, not full proof.

    z1=a, z2 is the first human solver, z3 the AI-worker boundary.
    The positive root of z2-a is 2/3; at a=0 use the limiting candidate.
    """
    validate_h(h)
    validate_ai(z_ai)
    a = z_ai
    if a > SWITCH:
        raise ValueError('configuration A requires a <= 2/3')
    z1 = a
    z2 = (a-h*a*a/2)/(1-h+h*a)
    z3 = z2+h*(a-a*a/2)
    residuals = (
        z3-(z2+a)*h*(1-a)-a,
        z3-z2-h*(a-a*a/2),
        z2+a-n_of(a, h)*(z3-a),
    )
    # Scale the last wage residual for small h, where n(a) is large.
    scale = max(1, abs(z2+a), abs(n_of(a, h)*(z3-a)))
    error = max(abs(residuals[0]), abs(residuals[1]), abs(residuals[2])/scale)
    if error > 1e-9:
        raise ArithmeticError('candidate equation residual')
    if not (0 <= z1 <= z2+1e-12 and z2 <= z3+1e-12 and z3 <= 1+1e-12):
        raise ArithmeticError('candidate occupation ordering')
    return dict(z1=z1, z2=z2, z3=z3, w_bottom=z2*(1-h),
                feasible=True, max_residual=error)


def z_switch(h):
    """Boundary of candidate A, conditional on the assumed structure."""
    validate_h(h)
    return SWITCH


def post_ai(h, z_ai):
    """Bottom wage: low candidate or conditional AI-assisted branch."""
    validate_h(h)
    validate_ai(z_ai)
    if z_ai <= SWITCH:
        return 'AI worker candidate', post_ai_config_a(h, z_ai)
    return 'AI solver (conditional)', {'w_bottom': z_ai*(1-h)}


def wage_top_autonomous(h, z_ai):
    """Zero-profit wage at z=1 conditional on supervising AI workers."""
    validate_h(h)
    validate_ai(z_ai)
    return 1/h


def wage_bottom_non_autonomous(h, z_ai, w_pre_bottom):
    validate_h(h)
    validate_ai(z_ai)
    return max(z_ai, w_pre_bottom)


def bottom_crossing(h):
    """Crossing of the piecewise endpoint exercise, not a general theorem."""
    w0 = pre_ai(h)[2](0)
    at_switch = SWITCH*(1-h)
    if w0 <= at_switch:
        root = bisect(lambda a: post_ai_config_a(h, a)['w_bottom']-w0, 0, SWITCH)
        return root, 'AI worker candidate'
    root = w0/(1-h)
    validate_ai(root)
    return root, 'AI solver (conditional)'


def main(h=0.5):
    t, c, wage, _ = pre_ai(h)
    w0, w1 = wage(0), wage(1)
    a_bar, regime = bottom_crossing(h)
    print(f'h={h}: t={t:.6f}, C={c:.6f}, w(0)={w0:.6f}, w(1)={w1:.6f}')
    print(f'candidate A boundary = {z_switch(h):.6f}')
    print(f'conditional autonomous bottom crossing = {a_bar:.6f} ({regime})')
    print(f'non-autonomous use threshold = {w0:.6f}')
    print('a     regime                      w*(0)     w*(1)*    w_na(0)')
    for a in [0.2, 0.425, 0.5, 0.6, 0.7, 0.72, 0.764, 0.85, 0.95]:
        label, sol = post_ai(h, a)
        print(f'{a:.3f} {label:27s} {sol["w_bottom"]:9.4f} {wage_top_autonomous(h,a):9.4f} {wage_bottom_non_autonomous(h,a,w0):9.4f}')
    print('* Top wage conditional on supervising AI workers; no full post-AI allocation solved.')


if __name__ == '__main__':
    main(float(sys.argv[1]) if len(sys.argv) > 1 else 0.5)
