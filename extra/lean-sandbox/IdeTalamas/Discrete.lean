/-
Discrete three-type version of Ide & Talamas (2025), "Artificial Intelligence in the
Knowledge Economy", JPE 133(12).  Source version: arXiv:2312.05481v11.

This file formalizes the statements of `extra/derivation/discrete-three-type.pdf` for the
case in which the AI replicates the middle type exactly (a = z₂):

* `span_strict_anti`      : Lemma 4, the solver's surplus is strictly decreasing in worker knowledge
* `bottom_gains_iff`      : Corollary 1, the capability threshold for winners at the bottom
* `share_identity`        : Corollary 3, the automated type's rent is shared among its workers
* `top_loses`             : Corollary 4, the most knowledgeable type loses relative to no AI
* `no_positive_profit_*`  : condition (N) for every admissible firm configuration
-/
import Mathlib

namespace IdeTalamas

/-- Primitives of the discrete three-type economy. -/
structure Params where
  h : ℝ
  z₁ : ℝ
  z₂ : ℝ
  z₃ : ℝ
  h_pos : 0 < h
  h_lt_one : h < 1
  z₁_nonneg : 0 ≤ z₁
  z₁_lt_z₂ : z₁ < z₂
  z₂_lt_z₃ : z₂ < z₃
  z₃_lt_one : z₃ < 1

namespace Params

variable (P : Params)

lemma z₁_lt_one : P.z₁ < 1 :=
  lt_trans (lt_trans P.z₁_lt_z₂ P.z₂_lt_z₃) P.z₃_lt_one

lemma z₂_lt_one : P.z₂ < 1 := lt_trans P.z₂_lt_z₃ P.z₃_lt_one

lemma z₂_nonneg : 0 ≤ P.z₂ := le_of_lt (lt_of_le_of_lt P.z₁_nonneg P.z₁_lt_z₂)

lemma z₃_nonneg : 0 ≤ P.z₃ :=
  le_of_lt (lt_trans (lt_of_le_of_lt P.z₁_nonneg P.z₁_lt_z₂) P.z₂_lt_z₃)

/-- Span of control: workers of knowledge `z` supervised by one solver. -/
noncomputable def n (z : ℝ) : ℝ := 1 / (P.h * (1 - z))

lemma n_pos {z : ℝ} (hz : z < 1) : 0 < P.n z :=
  div_pos one_pos (mul_pos P.h_pos (by linarith))

/-- `n z` and `h (1 - z)` are reciprocals: one worker's questions use `h (1 - z)` of solver time. -/
lemma n_mul_time {z : ℝ} (hz : z < 1) : P.n z * (P.h * (1 - z)) = 1 := by
  have hne : P.h * (1 - z) ≠ 0 := ne_of_gt (mul_pos P.h_pos (by linarith))
  unfold n
  exact one_div_mul_cancel hne

/-- Lemma 4: with workers paid their own output, a solver's surplus strictly falls in worker
knowledge, because the team shrinks faster than the surplus per worker grows. -/
theorem span_strict_anti {x y s : ℝ} (hx : x < y) (hy : y ≤ s) (hs : s < 1) :
    P.n y * (s - y) < P.n x * (s - x) := by
  have hy1 : y < 1 := lt_of_le_of_lt hy hs
  have hx1 : x < 1 := lt_trans hx hy1
  have hdx : (0:ℝ) < P.h * (1 - x) := mul_pos P.h_pos (by linarith)
  have hdy : (0:ℝ) < P.h * (1 - y) := mul_pos P.h_pos (by linarith)
  have hnx : P.n x * (P.h * (1 - x)) = 1 := P.n_mul_time hx1
  have hny : P.n y * (P.h * (1 - y)) = 1 := P.n_mul_time hy1
  have hprod : (0:ℝ) < P.h * (1 - x) * (P.h * (1 - y)) := mul_pos hdx hdy
  -- the algebraic core: (s - y) h (1 - x) < (s - x) h (1 - y), because the difference is
  -- h (y - x) (1 - s) > 0
  have core : (s - y) * (P.h * (1 - x)) < (s - x) * (P.h * (1 - y)) := by
    nlinarith [mul_pos P.h_pos (mul_pos (sub_pos.mpr hx) (sub_pos.mpr hs))]
  have expand_y : P.n y * (s - y) * (P.h * (1 - x) * (P.h * (1 - y)))
      = (s - y) * (P.h * (1 - x)) := by
    calc P.n y * (s - y) * (P.h * (1 - x) * (P.h * (1 - y)))
        = (P.n y * (P.h * (1 - y))) * ((s - y) * (P.h * (1 - x))) := by ring
      _ = (s - y) * (P.h * (1 - x)) := by rw [hny, one_mul]
  have expand_x : P.n x * (s - x) * (P.h * (1 - x) * (P.h * (1 - y)))
      = (s - x) * (P.h * (1 - y)) := by
    calc P.n x * (s - x) * (P.h * (1 - x) * (P.h * (1 - y)))
        = (P.n x * (P.h * (1 - x))) * ((s - x) * (P.h * (1 - y))) := by ring
      _ = (s - x) * (P.h * (1 - y)) := by rw [hnx, one_mul]
  have hmul : P.n y * (s - y) * (P.h * (1 - x) * (P.h * (1 - y)))
      < P.n x * (s - x) * (P.h * (1 - x) * (P.h * (1 - y))) := by
    rw [expand_y, expand_x]; exact core
  exact lt_of_mul_lt_mul_right hmul (le_of_lt hprod)

/-! ### Wages -/

/-- Pre-AI wage of the least knowledgeable type (Theorem 1): its own output. -/
noncomputable def wPre₁ : ℝ := P.z₁

/-- Pre-AI wage of the middle type (Theorem 1). -/
noncomputable def wPre₂ : ℝ := max P.z₂ (P.n P.z₁ * (P.z₂ - P.z₁))

/-- Pre-AI wage of the most knowledgeable type (Theorem 1). -/
noncomputable def wPre₃ : ℝ :=
  max (max P.z₃ (P.n P.z₁ * (P.z₃ - P.z₁))) (P.n P.z₂ * (P.z₃ - P.wPre₂))

/-- Post-AI wage of the least knowledgeable type (Theorem 2), with `a = z₂`.
Note `1 - 1 / n z₁ = 1 - h (1 - z₁)`. -/
noncomputable def wAut₁ : ℝ := max P.z₁ (P.z₂ * (1 - P.h * (1 - P.z₁)))

/-- Post-AI wage of the automated type (Corollary 3): it is priced at the rental rate of compute. -/
noncomputable def wAut₂ : ℝ := P.z₂

/-- Post-AI wage of the most knowledgeable type (Theorem 2), with `a = z₂`. -/
noncomputable def wAut₃ : ℝ :=
  max (max P.z₃ (P.n P.z₂ * (P.z₃ - P.z₂))) (P.n P.z₁ * (P.z₃ - P.wAut₁))

lemma z₁_le_wAut₁ : P.z₁ ≤ P.wAut₁ := le_max_left _ _

lemma bound_wAut₁ : P.z₂ * (1 - P.h * (1 - P.z₁)) ≤ P.wAut₁ := le_max_right _ _

lemma wAut₁_nonneg : 0 ≤ P.wAut₁ := le_trans P.z₁_nonneg P.z₁_le_wAut₁

lemma z₃_le_wAut₃ : P.z₃ ≤ P.wAut₃ := le_trans (le_max_left _ _) (le_max_left _ _)

/-! ### Corollaries -/

/-- Corollary 1: there are winners at the bottom iff the AI is capable enough.  Dividing by the
positive quantity `1 - h (1 - z₁)` puts the condition in threshold form,
`z₁ / (1 - h (1 - z₁)) < z₂`; it is a statement about capability, not about autonomy. -/
theorem bottom_gains_iff :
    P.wPre₁ < P.wAut₁ ↔ P.z₁ < P.z₂ * (1 - P.h * (1 - P.z₁)) := by
  have hden : (0:ℝ) < 1 - P.h * (1 - P.z₁) := by
    nlinarith [P.h_pos, P.h_lt_one, P.z₁_nonneg, P.z₁_lt_one]
  simp only [wPre₁, wAut₁, lt_max_iff]
  constructor
  · rintro (hcon | hgood)
    · exact absurd hcon (lt_irrefl _)
    · exact hgood
  · intro hgood
    exact Or.inr hgood

/-- Corollary 3: when the automated type earned a rent, the gain of the bottom type equals that
rent divided by the team size.  The rent lost by the automated type is shared, one to one, among
the workers it used to supervise. -/
theorem share_identity (hrent : P.z₂ < P.n P.z₁ * (P.z₂ - P.z₁))
    (hgain : P.z₁ < P.z₂ * (1 - P.h * (1 - P.z₁))) :
    P.wAut₁ - P.wPre₁ = (P.wPre₂ - P.wAut₂) / P.n P.z₁ := by
  have hn : (0:ℝ) < P.n P.z₁ := P.n_pos P.z₁_lt_one
  have htime : P.n P.z₁ * (P.h * (1 - P.z₁)) = 1 := P.n_mul_time P.z₁_lt_one
  have hw₂ : P.wPre₂ = P.n P.z₁ * (P.z₂ - P.z₁) := max_eq_right (le_of_lt hrent)
  have hw₁ : P.wAut₁ = P.z₂ * (1 - P.h * (1 - P.z₁)) := max_eq_right (le_of_lt hgain)
  rw [hw₁, hw₂, eq_div_iff (ne_of_gt hn)]
  simp only [wPre₁, wAut₂]
  linear_combination (-P.z₂) * htime

/-- Corollary 4: the most knowledgeable type loses relative to the pre-AI economy.  Both terms of
its post-AI wage are dominated: the AI team is smaller (Lemma 4) and the human team is more
expensive, while under (A1) the bottom type earned no rent that could be captured. -/
theorem top_loses : P.wAut₃ ≤ P.wPre₃ := by
  have h₁ : P.z₃ ≤ P.wPre₃ := le_trans (le_max_left _ _) (le_max_left _ _)
  have h₂ : P.n P.z₂ * (P.z₃ - P.z₂) ≤ P.wPre₃ := by
    have := P.span_strict_anti P.z₁_lt_z₂ (le_of_lt P.z₂_lt_z₃) P.z₃_lt_one
    exact le_trans (le_of_lt this) (le_trans (le_max_right _ _) (le_max_left _ _))
  have h₃ : P.n P.z₁ * (P.z₃ - P.wAut₁) ≤ P.wPre₃ := by
    have hn : (0:ℝ) < P.n P.z₁ := P.n_pos P.z₁_lt_one
    have : P.n P.z₁ * (P.z₃ - P.wAut₁) ≤ P.n P.z₁ * (P.z₃ - P.z₁) :=
      mul_le_mul_of_nonneg_left (by linarith [P.z₁_le_wAut₁]) (le_of_lt hn)
    exact le_trans this (le_trans (le_max_right _ _) (le_max_left _ _))
  exact max_le (max_le h₁ h₂) h₃

/-! ### Condition (N): no admissible configuration earns positive profit (autonomous AI, r = z₂) -/

/-- A top-automated firm (AI solver, workers of type 1) cannot earn a positive profit. -/
theorem no_positive_profit_tA₁ :
    P.n P.z₁ * (P.z₂ - P.wAut₁) - P.z₂ ≤ 0 := by
  have hn : (0:ℝ) < P.n P.z₁ := P.n_pos P.z₁_lt_one
  have htime : P.n P.z₁ * (P.h * (1 - P.z₁)) = 1 := P.n_mul_time P.z₁_lt_one
  have expand : P.z₂ - P.z₂ * (1 - P.h * (1 - P.z₁)) = P.z₂ * (P.h * (1 - P.z₁)) := by ring
  have hb : P.z₂ - P.wAut₁ ≤ P.z₂ * (P.h * (1 - P.z₁)) := by
    have := P.bound_wAut₁
    linarith [expand]
  have step : P.n P.z₁ * (P.z₂ - P.wAut₁) ≤ P.n P.z₁ * (P.z₂ * (P.h * (1 - P.z₁))) :=
    mul_le_mul_of_nonneg_left hb (le_of_lt hn)
  have eq0 : P.n P.z₁ * (P.z₂ * (P.h * (1 - P.z₁))) = P.z₂ := by
    linear_combination P.z₂ * htime
  linarith

/-- A two-layer human firm with a type-2 solver and type-1 workers cannot earn a positive profit.
This is the same inequality as `no_positive_profit_tA₁`, and it is what pins the automated type's
wage at `z₂`. -/
theorem no_positive_profit_21 :
    P.n P.z₁ * (P.z₂ - P.wAut₁) - P.wAut₂ ≤ 0 := P.no_positive_profit_tA₁

/-- A firm hiring a type-3 solver and AI workers cannot earn a positive profit. -/
theorem no_positive_profit_bA₃ :
    P.n P.z₂ * (P.z₃ - P.z₂) - P.wAut₃ ≤ 0 := by
  have : P.n P.z₂ * (P.z₃ - P.z₂) ≤ P.wAut₃ :=
    le_trans (le_max_right _ _) (le_max_left _ _)
  linarith

/-- A firm hiring a type-3 solver and type-1 workers cannot earn a positive profit. -/
theorem no_positive_profit_31 :
    P.n P.z₁ * (P.z₃ - P.wAut₁) - P.wAut₃ ≤ 0 := by
  have : P.n P.z₁ * (P.z₃ - P.wAut₁) ≤ P.wAut₃ := le_max_right _ _
  linarith

/-- One-layer human firms cannot earn a positive profit. -/
theorem no_positive_profit_one_layer :
    P.z₁ - P.wAut₁ ≤ 0 ∧ P.z₂ - P.wAut₂ ≤ 0 ∧ P.z₃ - P.wAut₃ ≤ 0 := by
  refine ⟨by linarith [P.z₁_le_wAut₁], by simp [wAut₂], by linarith [P.z₃_le_wAut₃]⟩

/-- A firm whose solver and workers are the same type cannot earn a positive profit, for any type
whose wage is at least its own output. -/
theorem no_positive_profit_same_type {z w : ℝ} (hz : z < 1) (hzw : z ≤ w) (hw : 0 ≤ w) :
    P.n z * (z - w) - w ≤ 0 := by
  have hn : (0:ℝ) < P.n z := P.n_pos hz
  nlinarith

end Params

end IdeTalamas

/-! ### Lemma 1: pure configurations are without loss of generality

A firm whose solver splits her time between several worker types has a profit that is *affine* in the
vector of time shares, over the simplex `{t ≥ 0, ∑ t ≤ 1}`.  An affine function on the simplex is
bounded by its values at the vertices, and the vertices are exactly the pure configurations: the
origin (a one-layer firm) and the unit vectors (a two-layer firm with a single worker type).  So
condition (N) on pure configurations implies condition (N) on every mixed firm. -/

/-- An affine combination over the simplex is bounded by an upper bound of its coefficients. -/
theorem affine_le_of_le {k : ℕ} (t c : Fin k → ℝ) (c₀ M : ℝ)
    (ht : ∀ j, 0 ≤ t j) (hsum : ∑ j, t j ≤ 1)
    (hc : ∀ j, c j ≤ M) (hc₀ : c₀ ≤ M) :
    (∑ j, t j * c j) + (1 - ∑ j, t j) * c₀ ≤ M := by
  have h1 : ∑ j, t j * c j ≤ ∑ j, t j * M :=
    Finset.sum_le_sum (fun j _ => mul_le_mul_of_nonneg_left (hc j) (ht j))
  have h2 : ∑ j, t j * M = (∑ j, t j) * M := by
    rw [← Finset.sum_mul]
  have h3 : (1 - ∑ j, t j) * c₀ ≤ (1 - ∑ j, t j) * M :=
    mul_le_mul_of_nonneg_left hc₀ (by linarith)
  have h4 : (∑ j, t j) * M + (1 - ∑ j, t j) * M = M := by ring
  linarith [h1, h3, h2.le, h2.ge]

/-- Lemma 1 in the form used by the derivation: if no pure configuration available to a solver earns
more than `M` (in the equilibrium argument, `M = 0`), then no mixed firm does either.
`c j` is the revenue of a team of workers of type `j` filling the solver's whole time, `z` is what the
solver produces alone, and `w` is her wage. -/
theorem mixed_firm_no_gain {k : ℕ} (t c : Fin k → ℝ) (z w M : ℝ)
    (ht : ∀ j, 0 ≤ t j) (hsum : ∑ j, t j ≤ 1)
    (hpure : ∀ j, c j - w ≤ M) (hone : z - w ≤ M) :
    (∑ j, t j * c j) + (1 - ∑ j, t j) * z - w ≤ M := by
  have h := affine_le_of_le t c z (M + w) ht hsum (fun j => by linarith [hpure j]) (by linarith)
  linarith

/-! ### Audit: every theorem above must rest only on Lean's three standard axioms
(`propext`, `Classical.choice`, `Quot.sound`).  Any occurrence of `sorryAx` would show up here. -/

#print axioms IdeTalamas.Params.span_strict_anti
#print axioms IdeTalamas.Params.bottom_gains_iff
#print axioms IdeTalamas.Params.share_identity
#print axioms IdeTalamas.Params.top_loses
#print axioms IdeTalamas.Params.no_positive_profit_tA₁
#print axioms IdeTalamas.Params.no_positive_profit_21
#print axioms IdeTalamas.Params.no_positive_profit_bA₃
#print axioms IdeTalamas.Params.no_positive_profit_31
#print axioms IdeTalamas.Params.no_positive_profit_one_layer
#print axioms IdeTalamas.Params.no_positive_profit_same_type
#print axioms IdeTalamas.Params.affine_le_of_le
#print axioms IdeTalamas.Params.mixed_firm_no_gain
