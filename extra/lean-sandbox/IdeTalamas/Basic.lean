/-
Ide & Talamàs (2025), "Artificial Intelligence in the Knowledge Economy", JPE 133(12).
Project scaffold only: this file checks that Mathlib is available.
The economic content will be formalized in later modules.
-/
import Mathlib

namespace IdeTalamas

/-- Sanity check that Mathlib's real-number API is available. -/
theorem mathlib_available (x : ℝ) : 0 ≤ x ^ 2 := sq_nonneg x

end IdeTalamas
