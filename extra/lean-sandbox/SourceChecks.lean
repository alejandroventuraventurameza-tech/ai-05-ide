import IT25KnowledgeEconomy.Assumptions

/-!
Independent proof/defect audit of the frozen source model in lean/.
These are not AppliedModelingLib-generated endpoints and do not prove
Propositions 5 or 6 in full. See extra/audit/LEAN_SOURCE_AUDIT.md.
-/

open MeasureTheory Set

namespace IT25KnowledgeEconomy.SourceAudit

/-- Updating the wage schedule does not change the current feasibility predicate. -/
theorem feasible_wage_free (E : Economy) (a : NonAutonomousOutcome)
    (zAI : ℝ) (w : ℝ → ℝ)
    (ha : nonAutonomousFeasible E zAI a) :
    nonAutonomousFeasible E zAI { a with wage := w } := by
  exact ha

/-- The current labor-income objective is unbounded on its stated comparison
domain: the feasible set leaves wages unconstrained. This diagnoses the
translation, not the source paper. -/
theorem no_labor_income_maximizer (E : Economy) (a : NonAutonomousOutcome)
    (zAI : ℝ) (hmass : E.distribution knowledgeSpace = 1) :
    ¬ nonAutonomousLaborIncomeMaximizing E zAI a := by
  intro h
  let b : NonAutonomousOutcome :=
    { a with wage := fun _ => laborIncome E a.wage + 1 }
  have hb : nonAutonomousFeasible E zAI b :=
    feasible_wage_free E a zAI _ h.1
  have hrestrict : (E.distribution.restrict knowledgeSpace) Set.univ = 1 := by
    simpa using hmass
  have hincome : laborIncome E b.wage = laborIncome E a.wage + 1 := by
    change (∫ _ : ℝ, (laborIncome E a.wage + 1)
      ∂(E.distribution.restrict knowledgeSpace)) = _
    rw [MeasureTheory.integral_const]
    simp [MeasureTheory.measureReal_def, hrestrict]
  have hbound := h.2 b hb
  rw [hincome] at hbound
  linarith

/-- With positive idle compute, the non-autonomous equilibrium rent is zero. -/
theorem nonautonomous_rent_zero_of_idle (E : Economy) (a : NonAutonomousOutcome)
    (zAI : ℝ) (heq : nonAutonomousEquilibrium E zAI a)
    (hidle : 0 < a.idleCompute) : a.rentalRate = 0 := by
  unfold nonAutonomousEquilibrium at heq
  rcases heq with ⟨_, _, _, _, _, _, _, _, _, hfree⟩
  exact hfree hidle

/-- With positive independently producing compute, the autonomous equilibrium
rental rate equals AI knowledge, by zero profit of one-layer AI firms. -/
theorem autonomous_rent_eq_of_independent (E : Economy) (a : AutonomousOutcome)
    (zAI : ℝ) (heq : autonomousEquilibrium E zAI a)
    (hactive : 0 < a.computeIndependent) : a.rentalRate = zAI := by
  unfold autonomousEquilibrium at heq
  rcases heq with ⟨_, _, _, _, _, _, _, _, _, _, _, _, hzero⟩
  have hp := hzero hactive
  unfold aiIndependentProfit at hp
  linarith

/-- Conditional wage equality for a human assisted by non-autonomous AI,
using positive team size and zero rent. No existence or occupation theorem
is assumed or claimed. -/
theorem nonautonomous_assisted_wage (E : Economy) (a : NonAutonomousOutcome)
    (zAI z : ℝ) (heq : nonAutonomousEquilibrium E zAI a)
    (hh : 0 < E.helpingCost) (hzAI : zAI < 1)
    (hidle : 0 < a.idleCompute) (hz : z ∈ a.aiAssistedWorkers) :
    a.wage z = zAI := by
  have hr := nonautonomous_rent_zero_of_idle E a zAI heq hidle
  unfold nonAutonomousEquilibrium at heq
  rcases heq with ⟨_, _, _, _, _, _, _, _, hworker, _⟩
  have hz1 := lt_trans (hworker z hz).1 hzAI
  have hn : 0 < teamSize E z := by
    unfold teamSize
    exact div_pos zero_lt_one (mul_pos hh (sub_pos.mpr hz1))
  have hp : teamSize E z * (zAI - a.wage z) = 0 := by
    simpa [aiSolverProfit, hr] using (hworker z hz).2
  rcases mul_eq_zero.mp hp with hzero | hzero
  · exact (ne_of_gt hn hzero).elim
  · linarith

#print axioms feasible_wage_free
#print axioms no_labor_income_maximizer
#print axioms nonautonomous_rent_zero_of_idle
#print axioms autonomous_rent_eq_of_independent
#print axioms nonautonomous_assisted_wage


/-- A feasible non-autonomous allocation with an economically funded wage bill.
The resource constraint permits free disposal, but not wages financed by
unmodelled transfers. The nonnegative rent is paid on all supplied compute. -/
def ResourceFeasible (E : Economy) (zAI : ℝ) (a : NonAutonomousOutcome) : Prop :=
  nonAutonomousFeasible E zAI a ∧
    0 ≤ a.rentalRate ∧
    laborIncome E a.wage + a.rentalRate * E.compute ≤ nonAutonomousOutput E zAI a

/-- Labor-income maximization among the resource-feasible alternatives. -/
def ResourceLaborIncomeMaximizing (E : Economy) (zAI : ℝ)
    (a : NonAutonomousOutcome) : Prop :=
  ResourceFeasible E zAI a ∧
    ∀ b, ResourceFeasible E zAI b → laborIncome E b.wage ≤ laborIncome E a.wage

/-- Given the aggregate income identity at a zero-rent efficient equilibrium,
resource feasibility is sufficient to transfer output maximality to labor
income. The identity and efficiency are explicit hypotheses, not proved here. -/
theorem resource_income_max_of_efficiency (E : Economy) (a : NonAutonomousOutcome)
    (zAI : ℝ) (hc : 0 ≤ E.compute)
    (heff : nonAutonomousEfficient E zAI a)
    (hr : a.rentalRate = 0)
    (hidentity : laborIncome E a.wage + a.rentalRate * E.compute =
      nonAutonomousOutput E zAI a) :
    ResourceLaborIncomeMaximizing E zAI a := by
  refine ⟨⟨heff.1, by simp [hr], hidentity.le⟩, ?_⟩
  intro b hb
  have hb1 := mul_nonneg hb.2.1 hc
  have hb2 := heff.2 b hb.1
  have ha : laborIncome E a.wage = nonAutonomousOutput E zAI a := by
    simpa [hr] using hidentity
  linarith [hb.2.2]

/-- Free entry into AI-solver firms imposes the wage floor of Proposition 6
for human types strictly below AI knowledge, conditional on zero rent. -/
theorem nonautonomous_wage_floor (E : Economy) (a : NonAutonomousOutcome)
    (zAI z : ℝ) (heq : nonAutonomousEquilibrium E zAI a)
    (hh : 0 < E.helpingCost) (hzAI : zAI < 1)
    (hr : a.rentalRate = 0) (hz : z ∈ knowledgeSpace)
    (hbelow : z < zAI) : zAI ≤ a.wage z := by
  unfold nonAutonomousEquilibrium at heq
  rcases heq with ⟨_, _, _, _, _, hprofit, _, _, _, _⟩
  have hn : 0 < teamSize E z := by
    unfold teamSize
    exact div_pos zero_lt_one (mul_pos hh (sub_pos.mpr (lt_trans hbelow hzAI)))
  have hp : teamSize E z * (zAI - a.wage z) ≤ 0 := by
    simpa [aiSolverProfit, hr] using hprofit z hz hbelow
  by_contra! h
  exact (not_lt_of_ge hp) (mul_pos hn (sub_pos.mpr h))

/-- If the pre-AI bottom wage is below AI knowledge, a zero-rent
non-autonomous equilibrium must raise that bottom wage strictly. This is a
pointwise result; it does not yet prove the occupational or neighborhood claim. -/
theorem bottom_strict_gain_of_capability (E : Economy) (pre : PreAIOutcome)
    (a : NonAutonomousOutcome) (zAI : ℝ)
    (hpre : preAIEquilibrium E pre)
    (heq : nonAutonomousEquilibrium E zAI a)
    (hh : 0 < E.helpingCost) (hzAI : zAI < 1)
    (hr : a.rentalRate = 0) (hcap : pre.wage 0 < zAI) :
    pre.wage 0 < a.wage 0 := by
  have hz : (0 : ℝ) ∈ knowledgeSpace := by simp [knowledgeSpace]
  have hw : 0 ≤ pre.wage 0 := hpre.2.1 0 hz
  exact lt_of_lt_of_le hcap
    (nonautonomous_wage_floor E a zAI 0 heq hh hzAI hr hz (lt_of_le_of_lt hw hcap))

/-- The exact same worker matching on the active domain suffices for
feasibility. Values on non-workers play no economic role. -/
theorem feasible_matching_extension (E : Economy) (a : NonAutonomousOutcome)
    (zAI : ℝ) (m : ℝ → ℝ)
    (ha : nonAutonomousFeasible E zAI a)
    (hm : ∀ z ∈ a.humanWorkers, m z = a.matching z) :
    nonAutonomousFeasible E zAI {a with matching := m} := by
  have hi (Y : Set ℝ) (hY : Y ⊆ a.humanWorkers) :
      m '' Y = a.matching '' Y := by
    ext x
    constructor
    · rintro ⟨y, hy, rfl⟩
      exact ⟨y, hy, (hm y (hY hy)).symm⟩
    · rintro ⟨y, hy, rfl⟩
      exact ⟨y, hy, hm y (hY hy)⟩
  unfold nonAutonomousFeasible at ha ⊢
  rcases ha with ⟨h1,h2,h3,h4,h5,h6,h7,h8,h9,h10,h11,h12,
    h13,h14,h15,h16,h17,h18,hmap,himage,hclear,hcomp,hbudget⟩
  refine ⟨h1,h2,h3,h4,h5,h6,h7,h8,h9,h10,h11,h12,
    h13,h14,h15,h16,h17,h18,?_,?_,?_,hcomp,hbudget⟩
  · intro z hz
    change m z ∈ a.humanSolvers
    rw [hm z hz]
    exact hmap hz
  · change m '' a.humanWorkers = a.humanSolvers
    rw [hi a.humanWorkers (Subset.rfl), himage]
  · intro Y hY hs
    change (∫ z in Y, E.helpingCost * (1-z) ∂E.distribution) =
      E.distribution.real (m '' Y)
    rw [hi Y hs]
    exact hclear Y hY hs

/-- The corresponding extension preserves the entire equilibrium predicate. -/
theorem equilibrium_matching_extension (E : Economy) (a : NonAutonomousOutcome)
    (zAI : ℝ) (m : ℝ → ℝ)
    (ha : nonAutonomousEquilibrium E zAI a)
    (hm : ∀ z ∈ a.humanWorkers, m z = a.matching z) :
    nonAutonomousEquilibrium E zAI {a with matching := m} := by
  unfold nonAutonomousEquilibrium at ha ⊢
  rcases ha with ⟨hf,h2,h3,h4,h5,h6,h7,hworker,h9,h10⟩
  refine ⟨feasible_matching_extension E a zAI m hf hm,h2,h3,h4,h5,h6,h7,?_,h9,h10⟩
  intro z hz
  change z < m z ∧ humanTeamProfit E a.wage z (m z) = 0
  rw [hm z hz]
  exact hworker z hz

/-- The original uniqueness predicate is false: a total matching function
can be altered at the endpoint 1, which cannot be a human worker matched to
a strictly more knowledgeable human solver. This is a translation defect. -/
theorem no_unique_nonautonomous_equilibrium (E : Economy) (zAI : ℝ) :
    ¬ uniqueNonAutonomousEquilibrium E zAI := by
  rintro ⟨a, ha, hunique⟩
  have hnot : (1 : ℝ) ∉ a.humanWorkers := by
    intro hworker
    have hf := ha.1
    unfold nonAutonomousFeasible at hf
    rcases hf with ⟨_,_,_,_,_,_,_,_,_,_,hsolver,_,_,_,_,_,_,_,hmap,_,_,_,_⟩
    have hs : a.matching 1 ∈ knowledgeSpace := hsolver (hmap hworker)
    have hle : a.matching 1 ≤ 1 := hs.2
    unfold nonAutonomousEquilibrium at ha
    rcases ha with ⟨_,_,_,_,_,_,_,hmatch,_,_⟩
    exact (not_lt_of_ge hle) (hmatch 1 hworker).1
  let m : ℝ → ℝ := fun z => if z = 1 then a.matching 1 + 1 else a.matching z
  have hm : ∀ z ∈ a.humanWorkers, m z = a.matching z := by
    intro z hz
    have hne : z ≠ 1 := by
      intro h
      subst z
      exact hnot hz
    simp [m, hne]
  let b : NonAutonomousOutcome := {a with matching := m}
  have hb : nonAutonomousEquilibrium E zAI b :=
    equilibrium_matching_extension E a zAI m ha hm
  have hequiv := hunique b hb
  unfold NonAutonomousOutcome.Equivalent at hequiv
  rcases hequiv with ⟨_,_,_,_,_,_,_,_,heq,_⟩
  have h1 : (1 : ℝ) ∈ knowledgeSpace := by simp [knowledgeSpace]
  have h := heq 1 h1
  change a.matching 1 = m 1 at h
  simp [m] at h

#print axioms resource_income_max_of_efficiency
#print axioms nonautonomous_wage_floor
#print axioms bottom_strict_gain_of_capability
#print axioms feasible_matching_extension
#print axioms equilibrium_matching_extension
#print axioms no_unique_nonautonomous_equilibrium

end IT25KnowledgeEconomy.SourceAudit
