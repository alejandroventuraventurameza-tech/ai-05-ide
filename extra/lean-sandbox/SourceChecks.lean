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

end IT25KnowledgeEconomy.SourceAudit
