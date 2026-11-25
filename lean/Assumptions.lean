import IT25KnowledgeEconomy.SourceModel

/-!
# Paper assumptions for Propositions 5 and 6

Only literal standing model hypotheses used by Propositions 5 and 6 live here.
The allocation, feasibility, profit, and equilibrium definitions are the
concrete definitions in `SourceModel.lean`; this file contains no abstract
equilibrium predicates and no result-level assumptions.
-/

namespace IT25KnowledgeEconomy

/--
The standing source assumptions: a continuous, strictly positive probability
density on `[0,1]`, `h,h₀ ∈ (0,1)` with `h<h₀`, and nonnegative compute.
-/
def ModelAssumptions (E : Economy) : Prop :=
  ContinuousOn E.density knowledgeSpace ∧
    (∀ z ∈ knowledgeSpace, 0 < E.density z) ∧
    E.distribution =
      (MeasureTheory.volume.restrict knowledgeSpace).withDensity
        (fun z ↦ ENNReal.ofReal (E.density z)) ∧
    E.distribution knowledgeSpace = 1 ∧
    E.helpingCost ∈ Set.Ioo 0 1 ∧
    E.helpingCostThreshold ∈ Set.Ioo 0 1 ∧
    E.helpingCost < E.helpingCostThreshold ∧
    0 ≤ E.compute

/-- Labor-income maximization among concrete non-autonomous feasible outcomes. -/
def nonAutonomousLaborIncomeMaximizing
    (E : Economy) (zAI : ℝ) (a : NonAutonomousOutcome) : Prop :=
  nonAutonomousFeasible E zAI a ∧
    ∀ b, nonAutonomousFeasible E zAI b →
      laborIncome E b.wage ≤ laborIncome E a.wage

end IT25KnowledgeEconomy
