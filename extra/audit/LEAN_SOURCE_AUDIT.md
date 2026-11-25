# Source-model proof and defect audit

Baseline: original generated lean/ folder from main commit 007b47c8bd91d070ad19a5d757749ccd0b082c2c. Its contents are not modified. Independent checks import the exact SourceModel.lean and Assumptions.lean from that tree; this is not the upstream paper_contribution.py check.

## 1. Discrete build failure and repair

Run [45579738670](https://github.com/alejandroventuraventurameza-tech/ai-05-ide/actions/runs/45579738670) failed on the last two print-axioms commands. Both affine_le_of_le and mixed_firm_no_gain are declared in the root namespace, after end IdeTalamas; the incorrect qualified references are removed. The ten preceding commands emitted the standard foundations. The proof statements and bodies are unchanged. The next CI run must confirm the fix; no build success is inferred from inspection.

## 2. Decisive defect: labor-income objective over unconstrained wages

Prop. 6 (arXiv v11, §6, printed p. 27) claims that the non-autonomous equilibrium maximizes labor income. In lean/Assumptions.lean, nonAutonomousLaborIncomeMaximizing requires that every nonAutonomousFeasible outcome have weakly lower labor income. But nonAutonomousFeasible (lean/SourceModel.lean) does not depend on wage or rentalRate. For any feasible outcome a, define b by keeping occupations, matching and compute fixed and replacing the wage schedule by the constant L(a)+1, where L(a)=∫w_a dG. Then b remains feasible. With G([0,1])=1, L(b)=L(a)+1, contradicting maximality. Thus no outcome satisfies the current predicate on a probability distribution, irrespective of existence or uniqueness of equilibrium. This is a defect of the translation, not a refutation of the paper.

Candidate repair: first establish the economic income identity at equilibrium (zero profits plus market clearing and integrability). For a feasible allocation, compare the total labor income attainable from that allocation under a resource/budget constraint, or compare the allocation's total output when rent is zero. Establish an exact bridge to the paper's interpretation rather than silently restricting the set of alternatives to equilibria or adding the desired conclusion. The proof of non-autonomous efficiency and its relation to labor-income maximization remain separate obligations.

## 3. Other source-model obligations

- h0 is an unconstrained primitive besides its range and h<h0; the source threshold is characterized by the pre-AI model. Derive the relationship with G or prove a source-consistent no-independent-production condition. Do not assume wage rents as a shortcut to Prop. 5.
- Unique non-autonomous equilibrium uses equality of matching on all of [0,1], even on non-workers, though feasibility and zero-profit conditions use it on the worker domain. The matching function is a total Lean function; changing it outside that domain can preserve all economics. Compare on the active domain (with a.e. boundary convention where appropriate) and audit whether the source warrants the precise equivalence.
- Set.integral uses a totalized integral; measurability and integrability of wages, matching and image sets need an explicit justification. The inverse employee function is currently Function.invFun of an unrestricted total function; establish an inverse on the source domain, not arbitrary extensions.
- Prop. 5 is conditional on an autonomous equilibrium family. Check abundance across the intended domain, existence and uniqueness, and non-vacuity of the quantifiers. The source's result is not a proof of this Lean Spec without those bridges.

## 4. Independent checked targets (pending CI)

The file extra/lean-sandbox/SourceChecks.lean attempts five small theorems against the original definitions:
1. Feasibility is invariant to wage replacement.
2. No labor-income maximizer exists under the current comparison predicate and mass-one hypothesis.
3. Non-autonomous rent is zero conditional on positive idle compute.
4. Autonomous rent equals AI knowledge conditional on positive independently producing compute.
5. An AI-assisted worker earns AI knowledge conditional on non-autonomous zero rent (derived from positive idle compute), positive helping cost and the admissible knowledge domain.

The latter three are conditional source-model lemmas, not full Props. 5/6. They do not prove that compute abundance implies the needed activity or idleness, nor any occupational characterization. The first two document a failed statement boundary rather than proof credit for a source theorem. All are candidates until CI elaborates them and audits the axioms.

## 5. Provenance

The instructor requests the full actual AppliedModelingLib output. The original folder remains as it was copied. No upstream revision identifier has been established from the available historical logs, no new upstream workflow run is claimed, and no generated metadata or reviewer receipt is fabricated. To repair that component properly, continue the genuine run on its pinned upstream checkout and regenerate/copy the folder as instructed. Until then this independent audit provides useful evidence, not a replacement for the official run.
