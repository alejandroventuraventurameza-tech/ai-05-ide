import math
import unittest
import equilibrium as e


class UniformEndpointTests(unittest.TestCase):
    def test_pre_ai_figure_3(self):
        t, _, w, m = e.pre_ai(0.5)
        self.assertAlmostEqual(t, 3-math.sqrt(5), places=10)
        self.assertAlmostEqual(w(0), 0.357, places=3)
        self.assertAlmostEqual(w(1), 1.58, places=2)
        self.assertAlmostEqual(m(t), 1)

    def test_figure_4(self):
        _, low = e.post_ai(0.5, 0.425)
        self.assertAlmostEqual(low['w_bottom'], 0.267, places=3)
        _, high = e.post_ai(0.5, 0.85)
        self.assertAlmostEqual(high['w_bottom'], 0.425)
        self.assertAlmostEqual(e.wage_top_autonomous(0.5, 0.425), 2)

    def test_candidate_equations_and_boundary(self):
        for h in (0.001, 0.01, 0.1, 0.5, 0.749):
            for a in (0, 0.001, 0.25, 0.425, 0.6, 2/3):
                sol = e.post_ai_config_a(h, a)
                self.assertTrue(sol['feasible'])
                self.assertLessEqual(sol['max_residual'], 1e-9)
            b = e.z_switch(h)
            sol = e.post_ai_config_a(h, b)
            self.assertAlmostEqual(sol['z2'], b)
            self.assertAlmostEqual(sol['w_bottom'], b*(1-h))

    def test_crossing_regimes(self):
        for h, branch in ((0.5, 'AI solver (conditional)'), (0.74, 'AI worker candidate')):
            w0 = e.pre_ai(h)[2](0)
            a, actual = e.bottom_crossing(h)
            self.assertEqual(actual, branch)
            self.assertAlmostEqual(e.post_ai(h, a)[1]['w_bottom'], w0, places=10)
            self.assertLess(e.post_ai(h, a-1e-5)[1]['w_bottom'], w0)
            self.assertGreater(e.post_ai(h, a+1e-5)[1]['w_bottom'], w0)
        a, _ = e.bottom_crossing(0.74)
        self.assertLess(a, 2/3)
        self.assertNotAlmostEqual(a, e.pre_ai(0.74)[2](0)/(1-0.74), places=6)

    def test_non_autonomous_threshold(self):
        w0 = e.pre_ai(0.5)[2](0)
        self.assertEqual(e.wage_bottom_non_autonomous(0.5, w0, w0), w0)
        self.assertEqual(e.wage_bottom_non_autonomous(0.5, 0, w0), w0)
        self.assertEqual(e.wage_bottom_non_autonomous(0.5, 0.9, w0), 0.9)

    def test_invalid_domain(self):
        for h in (0, -0.1, 0.75, 1, float('nan')):
            with self.assertRaises(ValueError):
                e.pre_ai(h)
        for a in (-0.1, 1, float('nan')):
            with self.assertRaises(ValueError):
                e.post_ai(0.5, a)
        with self.assertRaises(ValueError):
            e.post_ai_config_a(0.5, 0.8)
        with self.assertRaises(ValueError):
            e.bisect(lambda x: x*x+1, -1, 1)


if __name__ == '__main__':
    unittest.main()
