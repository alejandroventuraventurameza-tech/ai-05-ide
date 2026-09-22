import IT25KnowledgeEconomy.Assumptions

/-!
# Human-Facing Paper Interface: Artificial Intelligence in the Knowledge Economy

This is the compact Lean file a human should read after formalization to check
whether the paper's definitions and named theorem statements were represented
correctly. Keep the row-level dashboard and LLM audit statements in this file
for every paper. Move implementation details, proof aliases, and bulky helper
lemmas behind imported modules such as `AuditInterface.lean`, but expose the
audited paper-facing statements directly here; do not use
`paper_interface.audit_surface_path`.

Rules for completing this file:

- Keep the paper's definitions/formatted objects first, in source order.
- Expose the actual paper formulas here; do not only point to generic library
  definitions or implementation witnesses.
- A material reusable `AppliedModelingLib` primitive may remain a reference here only
  after `audit/library_semantic_review.json` records its exact bounded library
  declaration and an explicit byte-pinned paper-source connection. The
  dashboard and human-review packet show and source-check that declaration
  before the dependent Spec; a library name, docstring, or glossary is not a
  semantic bridge. Do not add a duplicate paper claim merely to restate it.
- If a named theorem needs a hypothesis that is not derived from earlier Lean
  declarations, declare that hypothesis in `Assumptions.lean` and list it in
  `status.json` `review_surface.assumption_names`.
- Then state the named results directly, with assumptions visible in each
  theorem signature by referencing named paper assumptions imported from
  `Assumptions.lean`.
- In the statement-first phase, write every complete source-facing statement as
  a transparent `<name>Spec : Prop` here, exactly once. Put the paired
  theorem/lemma of that exact type in `ProofInterface.lean`; its temporary
  proof body may be `by sorry` only in a private draft. This separation keeps
  the human semantic surface free of thin wrapper declarations.
- Before drafting that Lean surface, independently inventory every material
  source atom from exact pinned source quote bytes. Do not infer source atoms
  from declaration, binder, field, function, or source-map names.
- Run raw-source-to-expanded-Spec statement matching plus Lean-emitted
  premise/conclusion claim-atom review on the skeleton. The semantic comparison uses
  only byte-pinned source quotes (and separately pinned source context) against
  the expanded transparent Spec; map summaries and proof wrappers are not
  semantic inputs. Then freeze each canonical Lean declaration-manifest digest.
- In the proof phase, replace the `ProofInterface.lean` `sorry` with a short
  proof that calls into `MainTheorems.lean` or lower proof files without
  changing the specification or theorem type. Any specification/type change
  invalidates the freeze and requires a fresh statement audit.
- At formalized closeout, complete the v11 realization receipt: Lean Meta checks
  the theorem has exactly the transparent Spec type; each source atom is bound
  to the elaborated Spec surface; closure traversal includes proof and instance
  arguments; and every material terminal has a source, approved correction or
  additional assumption, checked derivation, or version-pinned foundation
  disposition. No data, container, or identifier-based exemption is allowed.
- The transparent `...Spec` is the sole semantic-review target for its source
  claim. The paired theorem/lemma is a proof endpoint whose exact Spec type is
  verified by Lean Meta, not a duplicate source-to-Lean comparison row.
- Keep proof endpoints, exhaustive endpoint aliases, and proof-seam checks in
  `ProofInterface.lean`, implementation modules, or `ProofLedger.lean`, not
  here. Do not create new `PostPaperAudit.lean` or `AuditLedger.lean` files;
  those names are legacy.

## Named Results

Each entry has one semantic-review target (`Spec`) and one proof endpoint (the
paired theorem/lemma). The human dashboard and review packet present that pair
once rather than treating the two declarations as duplicate paper claims.

- Proposition 5: winners at the bottom and top of the knowledge distribution.
- Proposition 6: equilibrium and welfare comparisons for non-autonomous AI.
-/

namespace IT25KnowledgeEconomy

/-- The set `B` of people weakly below AI knowledge who gain from autonomous AI. -/
def bottomWinners
    (pre : PreAIOutcome) (post : AutonomousOutcome) (zAI : ℝ) : Set ℝ :=
  {z | z ∈ Set.Icc 0 zAI ∧ pre.wage z < post.wage z}

/-- The set `T` of people weakly above AI knowledge who gain from autonomous AI. -/
def topWinners
    (pre : PreAIOutcome) (post : AutonomousOutcome) (zAI : ℝ) : Set ℝ :=
  {z | z ∈ Set.Icc zAI 1 ∧ pre.wage z < post.wage z}

/--
Proposition 5.  A single threshold `ζ` governs bottom winners across AI
knowledge levels, while top winners exist at every admissible AI knowledge
level.  `post zAI` selects the (earlier-proved unique) autonomous equilibrium.
-/
def proposition5_winnersSpec : Prop :=
  ∀ (E : Economy) (pre : PreAIOutcome)
      (post : ℝ → AutonomousOutcome),
    ModelAssumptions E →
    preAIEquilibrium E pre →
    (∀ zAI, ComputeAbundant E zAI →
      autonomousEquilibrium E zAI (post zAI)) →
    ∃ ζ, ζ ∈ interior pre.workers ∧
      ∀ zAI, ComputeAbundant E zAI →
        ((bottomWinners pre (post zAI) zAI).Nonempty ↔ ζ < zAI) ∧
          (topWinners pre (post zAI) zAI).Nonempty

/--
Proposition 6.  The statement keeps the unique-equilibrium claim separate from
the properties of every equilibrium, so uniqueness is not weakened to
uniqueness only among outcomes already satisfying the conclusions.
-/
def proposition6_nonAutonomousAISpec : Prop :=
  ∀ (E : Economy) (zAI : ℝ)
      (pre : PreAIOutcome) (autonomous : AutonomousOutcome),
    ModelAssumptions E →
    ComputeAbundant E zAI →
    preAIEquilibrium E pre →
    autonomousEquilibrium E zAI autonomous →
    uniqueNonAutonomousEquilibrium E zAI ∧
      ∀ nonAutonomous,
        nonAutonomousEquilibrium E zAI nonAutonomous →
        nonAutonomousEfficient E zAI nonAutonomous ∧
          nonAutonomousLaborIncomeMaximizing E zAI nonAutonomous ∧
          nonAutonomous.rentalRate = 0 ∧
          (zAI ≤ pre.wage 0 →
            nonAutonomous.aiAssistedWorkers = ∅ ∧
              nonAutonomous.humanWorkers = pre.workers ∧
              nonAutonomous.independentProducers = pre.independentProducers ∧
              nonAutonomous.humanSolvers = pre.solvers ∧
              ∀ z ∈ knowledgeSpace, nonAutonomous.wage z = pre.wage z) ∧
          (pre.wage 0 < zAI →
            LiesBelow nonAutonomous.aiAssistedWorkers
              (nonAutonomous.humanWorkers ∪
                nonAutonomous.independentProducers ∪
                nonAutonomous.humanSolvers) ∧
              nonAutonomous.aiAssistedWorkers.Nonempty ∧
              nonAutonomous.humanWorkers.Nonempty ∧
              nonAutonomous.humanSolvers.Nonempty) ∧
          nonAutonomousOutput E zAI nonAutonomous <
            autonomousOutput E zAI autonomous ∧
          (∃ z ∈ Set.Ioc 0 1,
            nonAutonomous.wage z ≤ pre.wage z ∧
              (pre.wage 0 < zAI → nonAutonomous.wage z < pre.wage z)) ∧
          (∃ ε > 0, ∀ z ∈ knowledgeSpace ∩ Set.Ico 0 ε,
            max (pre.wage z) (autonomous.wage z) ≤ nonAutonomous.wage z ∧
              (pre.wage 0 < zAI →
                max (pre.wage z) (autonomous.wage z) < nonAutonomous.wage z)) ∧
          (∃ ε > 0, ∀ z ∈ knowledgeSpace ∩ Set.Ioc (1 - ε) 1,
            nonAutonomous.wage z ≤ autonomous.wage z ∧
              (z ≠ 1 → nonAutonomous.wage z < autonomous.wage z))

end IT25KnowledgeEconomy
