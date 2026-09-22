import IT25KnowledgeEconomy.MainTheorems

/-!
# Paper Assumptions: Artificial Intelligence in the Knowledge Economy

This file is the only paper-local place for assumptions that are not derived in
Lean. Keep it small. Each declaration must be explicitly stated by the paper,
listed in `status.json` `review_surface.assumption_names`, and judged in
`audit/assumption_match_llm.json` as a true source/model assumption rather than a
proof convenience.

The audit discovers proposition-valued theorem premises from Lean's elaborated
claim manifests. Do not add `audit-premise` comments or duplicate a binder in a
sidecar to make it discoverable; instead, keep the proposition explicit in the
source-facing `Spec` and route any reusable paper assumption through this
module and `status.json`.

Start empty. Add a proposition here only after locating it as a literal source
antecedent. Never move an unproved lemma or target conclusion here merely to
make a statement skeleton compile.
-/

namespace IT25KnowledgeEconomy

/-- The paper's human-knowledge domain. -/
def knowledgeSpace : Set ℝ := Set.Icc 0 1

/-- A pre-AI equilibrium outcome, restricted to the data used by Propositions 5 and 6. -/
structure PreAIOutcome where
  workers : Set ℝ
  independentProducers : Set ℝ
  solvers : Set ℝ
  wage : ℝ → ℝ

/-- An autonomous-AI equilibrium outcome, restricted to wage and output comparisons. -/
structure AutonomousOutcome where
  wage : ℝ → ℝ
  output : ℝ

/--
A non-autonomous-AI outcome.  `aiAssistedWorkers` is the source set
`W_a^⋆`; the remaining occupation fields are `W_p^⋆`, `I^⋆`, and
`S_p^⋆`.
-/
structure NonAutonomousOutcome where
  aiAssistedWorkers : Set ℝ
  humanWorkers : Set ℝ
  independentProducers : Set ℝ
  humanSolvers : Set ℝ
  wage : ℝ → ℝ
  rentalRate : ℝ
  output : ℝ

/--
Only the model primitives needed to state Propositions 5 and 6.  The three
equilibrium predicates and the non-autonomous feasibility predicate are kept
abstract here; no conclusion of either proposition is included in them.
-/
structure EconomyPrimitives where
  density : ℝ → ℝ
  distribution : MeasureTheory.Measure ℝ
  helpingCost : ℝ
  helpingCostThreshold : ℝ
  compute : ℝ
  preAIEquilibrium : PreAIOutcome → Prop
  autonomousEquilibrium : ℝ → AutonomousOutcome → Prop
  nonAutonomousFeasible : ℝ → NonAutonomousOutcome → Prop
  nonAutonomousEquilibrium : ℝ → NonAutonomousOutcome → Prop

/--
The standing source assumptions used by Propositions 5 and 6: a continuous,
strictly positive unit-interval density; `h,h₀ ∈ (0,1)` with `h<h₀`; and
nonnegative compute.
-/
def ModelAssumptions (M : EconomyPrimitives) : Prop :=
  ContinuousOn M.density knowledgeSpace ∧
    (∀ z ∈ knowledgeSpace, 0 < M.density z) ∧
    M.distribution =
      (MeasureTheory.volume.restrict knowledgeSpace).withDensity
        (fun z ↦ ENNReal.ofReal (M.density z)) ∧
    M.distribution knowledgeSpace = 1 ∧
    M.helpingCost ∈ Set.Ioo 0 1 ∧
    M.helpingCostThreshold ∈ Set.Ioo 0 1 ∧
    M.helpingCost < M.helpingCostThreshold ∧
    0 ≤ M.compute

/-- Team size `n(z)=1/[h(1-z)]`. -/
noncomputable def teamSize (M : EconomyPrimitives) (z : ℝ) : ℝ :=
  1 / (M.helpingCost * (1 - z))

/-- The CDF `G(z)` induced by the model distribution. -/
def cdf (M : EconomyPrimitives) (z : ℝ) : ℝ :=
  M.distribution.real (Set.Iic z)

/--
The paper's displayed sufficient condition for compute to be abundant relative
to human time.
-/
def ComputeAbundant (M : EconomyPrimitives) (zAI : ℝ) : Prop :=
  zAI ∈ Set.Ico 0 1 ∧
    (∫ z in Set.Icc 0 zAI, (teamSize M z)⁻¹ ∂M.distribution) +
      teamSize M zAI * (1 - cdf M zAI) < M.compute

/-- The source notation `B ≼ B'`: `sup B ≤ inf B'`. -/
def LiesBelow (B B' : Set ℝ) : Prop :=
  sSup B ≤ sInf B'

/-- Total labor income under a wage schedule. -/
noncomputable def laborIncome
    (M : EconomyPrimitives) (wage : ℝ → ℝ) : ℝ :=
  ∫ z in knowledgeSpace, wage z ∂M.distribution

/-- Output efficiency among non-autonomous feasible outcomes. -/
def NonAutonomousEfficient
    (M : EconomyPrimitives) (zAI : ℝ) (a : NonAutonomousOutcome) : Prop :=
  M.nonAutonomousFeasible zAI a ∧
    ∀ b, M.nonAutonomousFeasible zAI b → b.output ≤ a.output

/-- Labor-income maximization among non-autonomous feasible outcomes. -/
def NonAutonomousLaborIncomeMaximizing
    (M : EconomyPrimitives) (zAI : ℝ) (a : NonAutonomousOutcome) : Prop :=
  M.nonAutonomousFeasible zAI a ∧
    ∀ b, M.nonAutonomousFeasible zAI b →
      laborIncome M b.wage ≤ laborIncome M a.wage

/--
Economic equality of non-autonomous outcomes; wage functions are compared only
on the source domain `[0,1]`.
-/
def NonAutonomousOutcome.Equivalent
    (a b : NonAutonomousOutcome) : Prop :=
  a.aiAssistedWorkers = b.aiAssistedWorkers ∧
    a.humanWorkers = b.humanWorkers ∧
    a.independentProducers = b.independentProducers ∧
    a.humanSolvers = b.humanSolvers ∧
    (∀ z ∈ knowledgeSpace, a.wage z = b.wage z) ∧
    a.rentalRate = b.rentalRate ∧
    a.output = b.output

/-- Uniqueness of the non-autonomous equilibrium up to economic equality. -/
def UniqueNonAutonomousEquilibrium
    (M : EconomyPrimitives) (zAI : ℝ) : Prop :=
  ∃ a, M.nonAutonomousEquilibrium zAI a ∧
    ∀ b, M.nonAutonomousEquilibrium zAI b → a.Equivalent b

end IT25KnowledgeEconomy
