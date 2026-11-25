import Mathlib

/-!
# Concrete source model for Ide--Talamàs (2025)

This module contains the competitive-equilibrium model used by Propositions 5
and 6.  Equilibrium is defined from allocations, matching/resource clearing,
firm profit maximization, and zero profit.  No conclusion of either proposition
is included in an equilibrium definition.
-/

namespace IT25KnowledgeEconomy

open scoped BigOperators ENNReal
open MeasureTheory Set

/-- Human knowledge is supported on `[0,1]`. -/
def knowledgeSpace : Set ℝ := Set.Icc 0 1

/-- Primitive data used by the pre-AI, autonomous, and non-autonomous models. -/
structure Economy where
  density : ℝ → ℝ
  distribution : Measure ℝ
  helpingCost : ℝ
  helpingCostThreshold : ℝ
  compute : ℝ

/-- Team size `n(z)=1/[h(1-z)]`. -/
noncomputable def teamSize (E : Economy) (z : ℝ) : ℝ :=
  1 / (E.helpingCost * (1 - z))

/-- The CDF `G(z)` induced by the model distribution. -/
def cdf (E : Economy) (z : ℝ) : ℝ :=
  E.distribution.real (Set.Iic z)

/-- The displayed sufficient condition for compute abundance. -/
def ComputeAbundant (E : Economy) (zAI : ℝ) : Prop :=
  zAI ∈ Set.Ico 0 1 ∧
    (∫ z in Set.Icc 0 zAI, (teamSize E z)⁻¹ ∂E.distribution) +
      teamSize E zAI * (1 - cdf E zAI) < E.compute

/-- The paper's notation `B ≼ B'`, meaning `sup B ≤ inf B'`. -/
def LiesBelow (B B' : Set ℝ) : Prop :=
  sSup B ≤ sInf B'

/-- Equality of occupation sets up to a `G`-null symmetric difference. -/
def occupationAEEq (E : Economy) (A B : Set ℝ) : Prop :=
  E.distribution.real ((A \ B) ∪ (B \ A)) = 0

/-! ## Firm profits -/

/-- A one-layer firm employing one human independent producer. -/
def humanIndependentProfit (wage : ℝ → ℝ) (z : ℝ) : ℝ :=
  z - wage z

/-- A two-layer firm with human workers of type `z` and a human solver `s`. -/
noncomputable def humanTeamProfit
    (E : Economy) (wage : ℝ → ℝ) (z s : ℝ) : ℝ :=
  teamSize E z * (s - wage z) - wage s

/-- A one-layer firm using an independently producing AI agent. -/
def aiIndependentProfit (zAI rentalRate : ℝ) : ℝ :=
  zAI - rentalRate

/-- A top-automated firm: an AI solver assists human workers. -/
noncomputable def aiSolverProfit
    (E : Economy) (zAI rentalRate : ℝ)
    (wage : ℝ → ℝ) (z : ℝ) : ℝ :=
  teamSize E z * (zAI - wage z) - rentalRate

/-- A bottom-automated firm: a human solver assists AI workers. -/
noncomputable def aiWorkerProfit
    (E : Economy) (zAI rentalRate : ℝ)
    (wage : ℝ → ℝ) (s : ℝ) : ℝ :=
  teamSize E zAI * (s - rentalRate) - wage s

/-! ## Pre-AI economy -/

/-- Pre-AI occupations, matching, and wages. -/
structure PreAIOutcome where
  workers : Set ℝ
  independentProducers : Set ℝ
  solvers : Set ℝ
  matching : ℝ → ℝ
  wage : ℝ → ℝ

/-- The inverse employee-matching function `e=m⁻¹`. -/
noncomputable def PreAIOutcome.employee (a : PreAIOutcome) : ℝ → ℝ :=
  Function.invFun a.matching

/-- Occupation and matching feasibility before AI. -/
def preAIFeasible (E : Economy) (a : PreAIOutcome) : Prop :=
  MeasurableSet a.workers ∧
    MeasurableSet a.independentProducers ∧
    MeasurableSet a.solvers ∧
    a.workers ⊆ knowledgeSpace ∧
    a.independentProducers ⊆ knowledgeSpace ∧
    a.solvers ⊆ knowledgeSpace ∧
    a.workers ∪ a.independentProducers ∪ a.solvers = knowledgeSpace ∧
    E.distribution.real (a.workers ∩ a.independentProducers) = 0 ∧
    E.distribution.real (a.workers ∩ a.solvers) = 0 ∧
    E.distribution.real (a.independentProducers ∩ a.solvers) = 0 ∧
    Set.MapsTo a.matching a.workers a.solvers ∧
    a.matching '' a.workers = a.solvers ∧
    (∀ Y, MeasurableSet Y → Y ⊆ a.workers →
      ∫ z in Y, E.helpingCost * (1 - z) ∂E.distribution =
        E.distribution.real (a.matching '' Y))

/--
Pre-AI competitive equilibrium.  Every admissible human firm has non-positive
profit; one-layer human firms and human teams used by the allocation earn zero.
-/
def preAIEquilibrium (E : Economy) (a : PreAIOutcome) : Prop :=
  preAIFeasible E a ∧
    (∀ z ∈ knowledgeSpace, 0 ≤ a.wage z) ∧
    (∀ z ∈ knowledgeSpace, humanIndependentProfit a.wage z ≤ 0) ∧
    (∀ z ∈ knowledgeSpace, ∀ s ∈ knowledgeSpace, z < s →
      humanTeamProfit E a.wage z s ≤ 0) ∧
    (∀ z ∈ a.independentProducers,
      humanIndependentProfit a.wage z = 0) ∧
    (∀ z ∈ a.workers,
      z < a.matching z ∧
        humanTeamProfit E a.wage z (a.matching z) = 0)

/-- Total pre-AI output. -/
noncomputable def preAIOutput (E : Economy) (a : PreAIOutcome) : ℝ :=
  (∫ z in a.independentProducers, z ∂E.distribution) +
    ∫ z in a.workers, a.matching z ∂E.distribution

/-- Pre-AI output efficiency. -/
def preAIEfficient (E : Economy) (a : PreAIOutcome) : Prop :=
  preAIFeasible E a ∧
    ∀ b, preAIFeasible E b → preAIOutput E b ≤ preAIOutput E a

/-! ## Autonomous-AI economy -/

/-- Autonomous-AI occupations, compute allocation, matching, and prices. -/
structure AutonomousOutcome where
  computeIndependent : ℝ
  computeWorkers : ℝ
  computeSolvers : ℝ
  independentProducers : Set ℝ
  humanWorkers : Set ℝ
  aiAssistedWorkers : Set ℝ
  humanSolvers : Set ℝ
  aiAssistedSolvers : Set ℝ
  matching : ℝ → ℝ
  wage : ℝ → ℝ
  rentalRate : ℝ

/-- Overall human worker set `W⁺=W_a⁺∪W_p⁺`. -/
def AutonomousOutcome.workers (a : AutonomousOutcome) : Set ℝ :=
  a.aiAssistedWorkers ∪ a.humanWorkers

/-- Overall human solver set `S⁺=S_a⁺∪S_p⁺`. -/
def AutonomousOutcome.solvers (a : AutonomousOutcome) : Set ℝ :=
  a.aiAssistedSolvers ∪ a.humanSolvers

noncomputable def AutonomousOutcome.employee (a : AutonomousOutcome) : ℝ → ℝ :=
  Function.invFun a.matching

/-- The five human occupation sets in the equilibrium-definition order. -/
def AutonomousOutcome.occupation (a : AutonomousOutcome) : Fin 5 → Set ℝ
  | ⟨0, _⟩ => a.independentProducers
  | ⟨1, _⟩ => a.humanWorkers
  | ⟨2, _⟩ => a.aiAssistedWorkers
  | ⟨3, _⟩ => a.humanSolvers
  | ⟨4, _⟩ => a.aiAssistedSolvers

def measurableAutonomousOccupations (a : AutonomousOutcome) : Prop :=
  ∀ i, MeasurableSet (a.occupation i)

def autonomousOccupationsInKnowledgeSpace (a : AutonomousOutcome) : Prop :=
  ∀ i, a.occupation i ⊆ knowledgeSpace

def autonomousOccupationsCover (a : AutonomousOutcome) : Prop :=
  (⋃ i, a.occupation i) = knowledgeSpace

def autonomousOccupationsDisjointAE (E : Economy) (a : AutonomousOutcome) : Prop :=
  ∀ i j, i ≠ j →
    E.distribution.real (a.occupation i ∩ a.occupation j) = 0

/-- Occupation, matching, compute, and market-clearing feasibility. -/
def autonomousFeasible
    (E : Economy) (zAI : ℝ) (a : AutonomousOutcome) : Prop :=
  zAI ∈ Set.Ico 0 1 ∧
    0 ≤ a.computeIndependent ∧
    0 ≤ a.computeWorkers ∧
    0 ≤ a.computeSolvers ∧
    measurableAutonomousOccupations a ∧
    autonomousOccupationsInKnowledgeSpace a ∧
    autonomousOccupationsCover a ∧
    autonomousOccupationsDisjointAE E a ∧
    Set.MapsTo a.matching a.humanWorkers a.humanSolvers ∧
    a.matching '' a.humanWorkers = a.humanSolvers ∧
    (∀ Y, MeasurableSet Y → Y ⊆ a.humanWorkers →
      ∫ z in Y, E.helpingCost * (1 - z) ∂E.distribution =
        E.distribution.real (a.matching '' Y)) ∧
    a.computeSolvers =
      ∫ z in a.aiAssistedWorkers,
        E.helpingCost * (1 - z) ∂E.distribution ∧
    a.computeWorkers =
      teamSize E zAI * E.distribution.real a.aiAssistedSolvers ∧
    a.computeIndependent + a.computeWorkers + a.computeSolvers = E.compute

/--
Autonomous competitive equilibrium.  All five admissible firm configurations
have non-positive profit, and each configuration used in the allocation has
zero profit.
-/
def autonomousEquilibrium
    (E : Economy) (zAI : ℝ) (a : AutonomousOutcome) : Prop :=
  autonomousFeasible E zAI a ∧
    (∀ z ∈ knowledgeSpace, 0 ≤ a.wage z) ∧
    0 ≤ a.rentalRate ∧
    (∀ z ∈ knowledgeSpace, humanIndependentProfit a.wage z ≤ 0) ∧
    aiIndependentProfit zAI a.rentalRate ≤ 0 ∧
    (∀ z ∈ knowledgeSpace, ∀ s ∈ knowledgeSpace, z < s →
      humanTeamProfit E a.wage z s ≤ 0) ∧
    (∀ z ∈ knowledgeSpace, z < zAI →
      aiSolverProfit E zAI a.rentalRate a.wage z ≤ 0) ∧
    (∀ s ∈ knowledgeSpace, zAI < s →
      aiWorkerProfit E zAI a.rentalRate a.wage s ≤ 0) ∧
    (∀ z ∈ a.independentProducers,
      humanIndependentProfit a.wage z = 0) ∧
    (∀ z ∈ a.humanWorkers,
      z < a.matching z ∧
        humanTeamProfit E a.wage z (a.matching z) = 0) ∧
    (∀ z ∈ a.aiAssistedWorkers,
      z < zAI ∧ aiSolverProfit E zAI a.rentalRate a.wage z = 0) ∧
    (∀ s ∈ a.aiAssistedSolvers,
      zAI < s ∧ aiWorkerProfit E zAI a.rentalRate a.wage s = 0) ∧
    (0 < a.computeIndependent → aiIndependentProfit zAI a.rentalRate = 0)

/-- Output of the five autonomous firm configurations. -/
noncomputable def autonomousOutput
    (E : Economy) (zAI : ℝ) (a : AutonomousOutcome) : ℝ :=
  (∫ z in a.independentProducers, z ∂E.distribution) +
    zAI * a.computeIndependent +
    (∫ z in a.humanWorkers, a.matching z ∂E.distribution) +
    (∫ z in a.aiAssistedSolvers,
      teamSize E zAI * z ∂E.distribution) +
    ∫ _z in a.aiAssistedWorkers, zAI ∂E.distribution

def autonomousEfficient
    (E : Economy) (zAI : ℝ) (a : AutonomousOutcome) : Prop :=
  autonomousFeasible E zAI a ∧
    ∀ b, autonomousFeasible E zAI b →
      autonomousOutput E zAI b ≤ autonomousOutput E zAI a

/-! ## Non-autonomous-AI economy -/

/--
Non-autonomous allocation.  `idleCompute` is the paper's reinterpreted
`μ_i`; non-autonomous AI cannot be an independent producer or a worker.
-/
structure NonAutonomousOutcome where
  idleCompute : ℝ
  computeSolvers : ℝ
  aiAssistedWorkers : Set ℝ
  humanWorkers : Set ℝ
  independentProducers : Set ℝ
  humanSolvers : Set ℝ
  matching : ℝ → ℝ
  wage : ℝ → ℝ
  rentalRate : ℝ

def NonAutonomousOutcome.workers (a : NonAutonomousOutcome) : Set ℝ :=
  a.aiAssistedWorkers ∪ a.humanWorkers

def NonAutonomousOutcome.solvers (a : NonAutonomousOutcome) : Set ℝ :=
  a.humanSolvers

noncomputable def NonAutonomousOutcome.employee
    (a : NonAutonomousOutcome) : ℝ → ℝ :=
  Function.invFun a.matching

/-- Occupation, matching, compute, and market-clearing feasibility. -/
def nonAutonomousFeasible
    (E : Economy) (zAI : ℝ) (a : NonAutonomousOutcome) : Prop :=
  zAI ∈ Set.Ico 0 1 ∧
    0 ≤ a.idleCompute ∧
    0 ≤ a.computeSolvers ∧
    MeasurableSet a.aiAssistedWorkers ∧
    MeasurableSet a.humanWorkers ∧
    MeasurableSet a.independentProducers ∧
    MeasurableSet a.humanSolvers ∧
    a.aiAssistedWorkers ⊆ knowledgeSpace ∧
    a.humanWorkers ⊆ knowledgeSpace ∧
    a.independentProducers ⊆ knowledgeSpace ∧
    a.humanSolvers ⊆ knowledgeSpace ∧
    a.aiAssistedWorkers ∪ a.humanWorkers ∪
        a.independentProducers ∪ a.humanSolvers = knowledgeSpace ∧
    E.distribution.real (a.aiAssistedWorkers ∩ a.humanWorkers) = 0 ∧
    E.distribution.real (a.aiAssistedWorkers ∩ a.independentProducers) = 0 ∧
    E.distribution.real (a.aiAssistedWorkers ∩ a.humanSolvers) = 0 ∧
    E.distribution.real (a.humanWorkers ∩ a.independentProducers) = 0 ∧
    E.distribution.real (a.humanWorkers ∩ a.humanSolvers) = 0 ∧
    E.distribution.real (a.independentProducers ∩ a.humanSolvers) = 0 ∧
    Set.MapsTo a.matching a.humanWorkers a.humanSolvers ∧
    a.matching '' a.humanWorkers = a.humanSolvers ∧
    (∀ Y, MeasurableSet Y → Y ⊆ a.humanWorkers →
      ∫ z in Y, E.helpingCost * (1 - z) ∂E.distribution =
        E.distribution.real (a.matching '' Y)) ∧
    a.computeSolvers =
      ∫ z in a.aiAssistedWorkers,
        E.helpingCost * (1 - z) ∂E.distribution ∧
    a.idleCompute + a.computeSolvers = E.compute

/--
Non-autonomous competitive equilibrium.  Its admissible configurations are a
one-layer human firm, a two-layer human firm, and a top-automated firm with an
AI solver.  Each has non-positive profit everywhere and zero profit when used.
-/
def nonAutonomousEquilibrium
    (E : Economy) (zAI : ℝ) (a : NonAutonomousOutcome) : Prop :=
  nonAutonomousFeasible E zAI a ∧
    (∀ z ∈ knowledgeSpace, 0 ≤ a.wage z) ∧
    0 ≤ a.rentalRate ∧
    (∀ z ∈ knowledgeSpace, humanIndependentProfit a.wage z ≤ 0) ∧
    (∀ z ∈ knowledgeSpace, ∀ s ∈ knowledgeSpace, z < s →
      humanTeamProfit E a.wage z s ≤ 0) ∧
    (∀ z ∈ knowledgeSpace, z < zAI →
      aiSolverProfit E zAI a.rentalRate a.wage z ≤ 0) ∧
    (∀ z ∈ a.independentProducers,
      humanIndependentProfit a.wage z = 0) ∧
    (∀ z ∈ a.humanWorkers,
      z < a.matching z ∧
        humanTeamProfit E a.wage z (a.matching z) = 0) ∧
    (∀ z ∈ a.aiAssistedWorkers,
      z < zAI ∧ aiSolverProfit E zAI a.rentalRate a.wage z = 0) ∧
    (0 < a.idleCompute → a.rentalRate = 0)

/-- Non-autonomous output. -/
noncomputable def nonAutonomousOutput
    (E : Economy) (zAI : ℝ) (a : NonAutonomousOutcome) : ℝ :=
  (∫ z in a.independentProducers, z ∂E.distribution) +
    (∫ z in a.humanWorkers, a.matching z ∂E.distribution) +
    ∫ _z in a.aiAssistedWorkers, zAI ∂E.distribution

/-- Total labor income under a wage schedule. -/
noncomputable def laborIncome (E : Economy) (wage : ℝ → ℝ) : ℝ :=
  ∫ z in knowledgeSpace, wage z ∂E.distribution

def nonAutonomousEfficient
    (E : Economy) (zAI : ℝ) (a : NonAutonomousOutcome) : Prop :=
  nonAutonomousFeasible E zAI a ∧
    ∀ b, nonAutonomousFeasible E zAI b →
      nonAutonomousOutput E zAI b ≤ nonAutonomousOutput E zAI a

/-- Economic equality of non-autonomous outcomes on the source domain. -/
def NonAutonomousOutcome.Equivalent
    (E : Economy) (zAI : ℝ) (a b : NonAutonomousOutcome) : Prop :=
  a.idleCompute = b.idleCompute ∧
    a.computeSolvers = b.computeSolvers ∧
    a.aiAssistedWorkers = b.aiAssistedWorkers ∧
    a.humanWorkers = b.humanWorkers ∧
    a.independentProducers = b.independentProducers ∧
    a.humanSolvers = b.humanSolvers ∧
    (∀ z ∈ knowledgeSpace, a.wage z = b.wage z) ∧
    a.rentalRate = b.rentalRate ∧
    (∀ z ∈ knowledgeSpace, a.matching z = b.matching z) ∧
    nonAutonomousOutput E zAI a = nonAutonomousOutput E zAI b

/-- Unique non-autonomous equilibrium modulo null occupation boundaries. -/
def uniqueNonAutonomousEquilibrium (E : Economy) (zAI : ℝ) : Prop :=
  ∃ a, nonAutonomousEquilibrium E zAI a ∧
    ∀ b, nonAutonomousEquilibrium E zAI b → a.Equivalent E zAI b

end IT25KnowledgeEconomy
