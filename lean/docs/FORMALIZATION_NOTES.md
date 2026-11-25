# Formalization Notes

This file preserves the previous hand-written paper-folder README content.
The paper-folder `README.md` is now a generated status overview.

# Artificial Intelligence in the Knowledge Economy

## Source Version

- Paper: *Artificial Intelligence in the Knowledge Economy*
- Authors: Enrique Ide and Eduard Talamàs
- Version formalized: arXiv v11, 2025-02-24
- Official URL: https://doi.org/10.1086/737233
- Public PDF: https://arxiv.org/pdf/2312.05481v11.pdf

Without a statement spec, a downloaded PDF is cached as `source.pdf` and ignored
by Git. A statement spec's SHA-256-verified source bytes are copied to a stable
paper-local `source-audited.*` path recorded in `audit/paper_statement_map.json`.
These artifacts are ignored by default. Unignore one only after an explicit
redistribution-rights review; machines without the private bytes must leave the
source-evidence gate unresolved rather than accepting the digest alone.
The extracted text cache is `source.txt` when `pdftotext` succeeds, and is also
ignored by Git in public workspaces unless redistribution rights have been
checked separately.

## Paper-Facing Ledger

- Implementation theorem file: `IT25KnowledgeEconomy/MainTheorems.lean`
- Source-semantic interface: `IT25KnowledgeEconomy/PaperInterface.lean`
- Proof-endpoint interface: `IT25KnowledgeEconomy/ProofInterface.lean`
- Machine-readable status source: `IT25KnowledgeEconomy/status.json`
- Private outside-Lean proof plan: `IT25KnowledgeEconomy/docs/FORMALIZATION_PLAN.md`
- Final validation report: `IT25KnowledgeEconomy/FINAL_VALIDATION_REPORT.md`
- Dependency DAG: `IT25KnowledgeEconomy/docs/DependencyDAG.tex`
- Rendered DAG: `IT25KnowledgeEconomy/docs/DependencyDAG.pdf`
- LLM/source audit sidecars: `IT25KnowledgeEconomy/audit/*.json`

`PaperInterface.lean` should be readable on its own: expose actual source
definitions/models and one transparent statement specification for each
selected source claim. Put each distinct theorem/lemma proof endpoint in
`ProofInterface.lean`, with a short closed proof that calls into
`MainTheorems.lean`. Do not duplicate the proof endpoint in the semantic
interface. Do not mark a row `formalized` unless the endpoint is closed and the
remaining assumptions cell is `None`.
Keep the dashboard surface curated but complete for source-labelled formal
material: definitions, formulas, propositions, theorems/corollaries, named
claims, and main-text lemmas that a reviewer or LLM-as-judge should inspect.
Do not omit source-visible named material merely to keep the dashboard compact.
Inventory every named appendix theorem, corollary, lemma, and definition under
the paper's single `closeout_review_policy`. The prospective default gives all
named theory an initial source-to-Lean review and repeats terminal adversarial
review for main-text material plus any explicitly promoted appendix item that
governs it. Record one complete content-pinned `source_region_partition`; do not
infer a tier from a Lean name, helper name, or proof location. Catalog
unnumbered prose assertions separately. They are claim-bearing but are not
independent theorem targets under named-theory scope unless the chosen policy
explicitly selects all prose.

Use the controlled status vocabulary from `../../docs/STATUS.md`. Public-facing
rows should use `partially formalized` for results that still depend on an
external theorem, certificate, or proof boundary, and should name that boundary
in the final column rather than using `conditional` as a separate status label.
Keep theorem/status content synchronized with the current Lean graph before
marking a row `formalized`. The planner creates the final Dependency DAG later,
from that stable graph. Keep `status.json` as the source of truth for review
rows, artifact paths, and the paper's top-level public status.

## Current Workflow

1. Byte-pin the exact source version and complete the source-only inventory,
   formula sanity pass, scope decisions, shared-library search, and
   `docs/FORMALIZATION_WORKING_MEMO.md`.
2. Put actual source models/definitions and one complete transparent
   `<name>Spec : Prop` per selected source claim in `PaperInterface.lean`.
   Put its distinct theorem/lemma endpoint in `ProofInterface.lean`; use
   `by sorry` only as a temporary private proof body.
3. Run the one non-certifying architecture pre-pass, repair role confusion or
   hidden result packages, and materialize the reviewed source map from
   `audit/v11_source_map_preparation_config.json`.
4. Prove the fixed Specs with targeted Lean builds. Record possible source
   clarifications, genuine additional assumptions, and proof deviations in the
   working memo; it is a lead log, not evidence.
5. Begin or resume audit and closeout with
   `python3 scripts/closeout_reuse_plan.py --paper IT25KnowledgeEconomy` and execute only
   its `next_action`.

The current semantic judge compares the ordered byte-pinned source-anchor
bundle directly with the fully expanded transparent Spec emitted by Lean. A
Lean-to-TeX translation, curator paraphrase, theorem name, wrapper theorem,
source-map summary, or code location is never semantic evidence. The same
standard applies to material paper-local and reusable-library prerequisites;
Lean's graph owns recursive declarations, premises, proof routes, instances,
and axiom closure.

Do not generate legacy `lean_to_tex_llm.json`,
`statement_match_llm.json`, `review_surface_llm.json`,
`paper_coverage_llm.json`, `source_record_audit.json`, or
`source_record_match_llm.json` for this current-protocol paper. The planner
schedules current graph acquisition, semantic-review deltas, complete
tracked-module elaboration, theorem realization, final holistic source review,
terminal report/DAG/status work, and the one issuer-protected strict
transaction.

The dashboard and PDF packet are optional human-review presentations generated
from the current graph after the source map and interfaces are stable. Human
annotations may not be fabricated or auto-closed, but missing annotations do
not block Lean closeout.

## Theorem Status

| Paper item | Lean declaration | Status | File | Remaining assumptions / notes |
|---|---|---|---|---|
| No source-pinned targets supplied | `none` | not started | `none` | Do not add a generic `True` theorem; extract exact source statements first |

## Intake Checklist

- [ ] Pin the exact source bytes and version.
- [ ] Complete the source-only selected-presentation and material-atom inventory.
- [ ] Complete the outside-Lean formula/dependency sanity pass and working memo.
- [ ] Search Mathlib, Cslib, Optlib, AppliedModelingLib, and relevant upstream
      Lean sources before introducing paper-local abstractions.
- [ ] Create actual source definitions/models and one transparent Spec per
      selected claim in `PaperInterface.lean`.
- [ ] Create each distinct proof endpoint in `ProofInterface.lean`.
- [ ] Run the architecture pre-pass and repair role confusion before freezing
      the source map and beginning expensive proof work.
- [ ] Keep final validation reports and Dependency DAGs absent until the
      planner schedules terminal closeout documents.

## Closeout Checklist

- [ ] Start with `python3 scripts/closeout_reuse_plan.py --paper IT25KnowledgeEconomy` and
      execute only its current `next_action`.
- [ ] Resolve every raw-source-to-expanded-Spec, material-prerequisite,
      assumption, proof-route, axiom, realization, and source-coverage finding.
- [ ] Let the complete tracked-module checkpoint use the Git-owned module
      inventory and one dependency-aware `lake --rehash build` transaction.
- [ ] When `complete_terminal_closeout_documents` is scheduled, write the
      final report and paper-facing DAG from the current graph, compile and
      visually inspect the DAG, update paper-local status, and replan.
- [ ] Complete the independent holistic source audit only after the final
      source/interface/proof surface is fixed. Record each required distinct
      reviewer and exact audit-document hash in
      `docs/FINAL_ADVERSARIAL_REVIEW_PANEL.json`; a later count increase keeps
      valid prior entries for unchanged comparison material and adds only the
      missing review.
- [ ] Run only the exact strict worker command printed for the frozen plan.
      Acceptance exists only when that in-process transaction publishes the
      accepted obligation graph.
- [ ] Generate the packet/dashboard from the accepted current graph for optional
      human review; never manufacture reviewer annotations.
