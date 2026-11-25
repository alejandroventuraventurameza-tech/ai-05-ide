"""Randomized property test for the discrete three-type theorems.

No worked example: the script draws primitives at random subject to (A1)-(A3), builds the
wage vectors of Theorems 1-3, and checks

  (N)  no admissible firm configuration earns strictly positive profit;
  (Z)  the configuration attaining each type's wage breaks even;
  plus every corollary: the two capability thresholds, the share-effect identity,
  w3* >= w3(non-autonomous), and w3* <= w3(pre-AI) when a = z2.

Standard library only. Run: python3 code/discrete_check.py [draws]
"""

import random
import sys

TOL = 1e-9


def n_of(z, h):
    return 1.0 / (h * (1.0 - z))


def pre_ai_wages(h, z):
    n1, n2 = n_of(z[0], h), n_of(z[1], h)
    w1 = z[0]
    w2 = max(z[1], n1 * (z[1] - z[0]))
    w3 = max(z[2], n1 * (z[2] - w1), n2 * (z[2] - w2))
    return [w1, w2, w3]


def autonomous_wages(h, z, a):
    n1, n2, na = n_of(z[0], h), n_of(z[1], h), n_of(a, h)
    w1 = max(z[0], a * (1.0 - 1.0 / n1)) if z[0] <= a else z[0]
    cand2 = [z[1], n1 * (z[1] - w1)]
    if z[1] <= a:
        cand2.append(a * (1.0 - 1.0 / n2))
    if z[1] >= a:
        cand2.append(na * (z[1] - a))
    w2 = max(cand2)
    w3 = max(z[2], na * (z[2] - a), n1 * (z[2] - w1), n2 * (z[2] - w2))
    return [w1, w2, w3]


def non_autonomous_wages(h, z, a):
    n1, n2 = n_of(z[0], h), n_of(z[1], h)
    w1 = max(z[0], a) if z[0] <= a else z[0]
    cand2 = [z[1], n1 * (z[1] - w1)]
    if z[1] <= a:
        cand2.append(a)
    w2 = max(cand2)
    w3 = max(z[2], n1 * (z[2] - w1), n2 * (z[2] - w2))
    return [w1, w2, w3]


def max_profit(h, z, w, r, a=None, autonomous=True):
    """Largest profit over all admissible configurations (must be <= 0 in equilibrium)."""
    best = max(z[i] - w[i] for i in range(3))                      # one-layer human
    for i in range(3):
        for j in range(3):
            if z[j] <= z[i]:
                best = max(best, n_of(z[j], h) * (z[i] - w[j]) - w[i])
    if a is not None:
        for j in range(3):
            if z[j] <= a:
                best = max(best, n_of(z[j], h) * (a - w[j]) - r)   # AI solver
        if autonomous:
            best = max(best, a - r)                                # one-layer AI
            for i in range(3):
                if z[i] >= a:
                    best = max(best, n_of(a, h) * (z[i] - r) - w[i])
    return best


def allocation_feasible(h, z, a, masses, w, autonomous=None):
    """Build the allocation of Lemma 5 and check that masses and compute suffice.

    Returns (ok, detail). `autonomous` is None for the pre-AI economy.
    """
    mu1, mu2, mu3, mu = masses
    n1, n2 = n_of(z[0], h), n_of(z[1], h)
    na = n_of(a, h) if a is not None else 0.0

    # which branch attains w3, and what it demands
    demand1 = demand2 = compute = 0.0
    if abs(w[2] - n1 * (z[2] - w[0])) <= TOL:
        demand1 += n1 * mu3
    elif abs(w[2] - n2 * (z[2] - w[1])) <= TOL:
        demand2 += n2 * mu3
    elif autonomous and abs(w[2] - na * (z[2] - a)) <= TOL:
        compute += na * mu3
    elif abs(w[2] - z[2]) > TOL:
        return False, "w3 attained by no admissible configuration"

    if demand2 > mu2 + TOL:
        return False, "not enough type-2 workers"
    rest2 = mu2 - demand2

    # which branch attains w2 for the remaining type-2 humans
    if abs(w[1] - n1 * (z[1] - w[0])) <= TOL:
        demand1 += n1 * rest2
    elif abs(w[1] - z[1]) <= TOL:
        pass                                             # independent producers
    elif a is not None and abs(w[1] - (a if not autonomous else a * (1 - 1 / n2))) <= TOL:
        compute += rest2 / n2                            # supervised by an AI solver
    elif autonomous and abs(w[1] - na * (z[1] - a)) <= TOL:
        compute += na * rest2
    else:
        return False, "w2 attained by no admissible configuration"

    if demand1 > mu1 + TOL:
        return False, "not enough type-1 workers"
    rest1 = mu1 - demand1

    # the remaining type-1 humans
    if abs(w[0] - z[0]) <= TOL:
        pass                                             # independent producers
    elif a is not None and abs(w[0] - (a if not autonomous else a * (1 - 1 / n1))) <= TOL:
        compute += rest1 / n1
    else:
        return False, "w1 attained by no admissible configuration"

    if compute > mu + TOL:
        return False, "not enough compute"
    return True, ""


def draw():
    """Primitives satisfying the ordering and (A1)-(A3)."""
    h = random.uniform(0.05, 0.95)
    z = sorted(random.uniform(0.0, 0.99) for _ in range(3))
    if z[2] <= z[1] or z[1] <= z[0]:
        return None
    a = random.uniform(z[0], z[2] - 1e-6)          # (A0): z1 <= a < z3
    n1, n2, na = n_of(z[0], h), n_of(z[1], h), n_of(a, h)
    mu3 = random.uniform(0.05, 1.0)
    mu2 = n2 * mu3 * random.uniform(1.01, 3.0)                     # (A2)
    mu1 = n1 * (mu2 + mu3) * random.uniform(1.01, 3.0)             # (A1)
    mu = (mu1 / n1 + mu2 / n2 + na * (mu2 + mu3)) * 1.5            # (A3)
    return h, z, a, (mu1, mu2, mu3, mu)


def main(draws=20000):
    random.seed(0)
    failures = {"N pre": 0, "N aut": 0, "N non": 0, "threshold aut": 0,
                "threshold non": 0, "identity": 0, "top prefers aut": 0, "top loses": 0,
                "feasible pre": 0, "feasible aut": 0, "feasible non": 0}
    tested = 0
    while tested < draws:
        got = draw()
        if got is None:
            continue
        h, z, a, (mu1, mu2, mu3, mu) = got
        tested += 1
        n1 = n_of(z[0], h)
        w = pre_ai_wages(h, z)
        w_a = autonomous_wages(h, z, a)
        w_n = non_autonomous_wages(h, z, a)

        if max_profit(h, z, w, 0.0) > TOL:
            failures["N pre"] += 1
        if max_profit(h, z, w_a, a, a, True) > TOL:
            failures["N aut"] += 1
        if max_profit(h, z, w_n, 0.0, a, False) > TOL:
            failures["N non"] += 1

        for key, args in (("feasible pre", (None, None, w)),
                          ("feasible aut", (a, True, w_a)),
                          ("feasible non", (a, False, w_n))):
            aa, auto, wv = args
            ok, _ = allocation_feasible(h, z, aa, (mu1, mu2, mu3, mu), wv, auto)
            if not ok:
                failures[key] += 1

        z_bar = z[0] / (1.0 - h * (1.0 - z[0]))
        if (w_a[0] > w[0] + TOL) != (a > z_bar + TOL):
            failures["threshold aut"] += 1
        if (w_n[0] > w[0] + TOL) != (a > z[0] + TOL):
            failures["threshold non"] += 1
        if w_a[2] < w_n[2] - TOL:
            failures["top prefers aut"] += 1

        # corollaries that assume the AI replicates the middle type exactly
        w_a2 = autonomous_wages(h, [z[0], z[1], z[2]], z[1])
        w2 = pre_ai_wages(h, z)
        if abs(w_a2[1] - z[1]) > TOL:
            failures["identity"] += 1
        elif z[1] > z_bar + TOL:
            lhs, rhs = w_a2[0] - w2[0], (w2[1] - w_a2[1]) / n1
            if abs(lhs - rhs) > 1e-8:
                failures["identity"] += 1
        if w_a2[2] > w2[2] + TOL:
            failures["top loses"] += 1

    print(f"draws tested: {tested}")
    for k, v in failures.items():
        print(f"  {k:18s} failures: {v}")
    print("ALL PROPERTIES HOLD" if not any(failures.values()) else "SOME PROPERTY FAILED")


if __name__ == "__main__":
    main(int(sys.argv[1]) if len(sys.argv) > 1 else 20000)
