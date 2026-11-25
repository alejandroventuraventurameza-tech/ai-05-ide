# Economic and formalization audit — Repository 5

**Baseline:** main commit 007b47c8bd91d070ad19a5d757749ccd0b082c2c. Source: Ide & Talamàs, arXiv v11, §§3–6 (printed pp. 13–27). Candidate, not final.

| Claim | Evidence / domain | Disposition |
|---|---|---|
| Prop. 5: bottom winners iff $a>\bar a$, $\bar a\in\operatorname{int}W$; top winners for all $a\in[0,1)$ | §5.2, pp. 24–25; standing assumptions $h<h_0$, abundant compute, positive continuous density | source result, not proved in our Lean |
| $w^*(0)=a(1-h)$ | Prop. 2, p. 19, if bottom uses AI as solver | conditional, not global |
| $w^*(1)=1/h$ from AI-worker zero profit | Prop. 2, p. 19, when top supervises AI | conditional derivation |
| Prop. 6: rent zero, use iff $a>w(0)$, output and wage comparisons | §6, p. 27 | preserve all weak/strict inequalities |
| Discrete bottom threshold $z_1/[1-h(1-z_1)]$ | three-type derivation (A0)–(A3), sandbox specializes $a=z_2$ | discrete, not continuum |
| Discrete share identity | sandbox share_identity assumes middle type earned rent, bottom gains and $a=z_2$ | historically Lean-checked under exact hypotheses |
| Top type may lose | sandbox top_loses gives weak inequality, $a=z_2$, different occupation assumptions | not a counterexample to Prop. 5 |

## Uniform candidate regime

For uniform G and $0<h<3/4$, in the candidate with human workers followed by independent producers and human solvers, let $a=z_{AI}$, $z_1=a$, $z_2$ be the first human solver and $z_3$ the boundary with solvers supervising AI workers. Matching gives $z_3=z_2+h(a-a^2/2)$. Continuity at $z_1=a$ requires

$$z_2+h(a-a^2/2)-(z_2+a)h(1-a)=a,$$

hence

$$z_2=\frac{a-ha^2/2}{1-h+ha},\qquad z_2-a=\frac{ha(1-3a/2)}{1-h+ha}.$$

For $a>0$ the independent-producer interval closes at $a=2/3$. This is the boundary of the candidate regime, conditional on its stated structure; it is not by itself proof of existence or uniqueness of the complementary regime. The high-knowledge branch in the existing code reports an AI-assisted worker wage rather than solving the complete matching problem. The crossing $w(0)/(1-h)$ applies only if the equilibrium is in that branch at the crossing.

Do not identify the discrete threshold with the continuum one by setting $z_1=0$: the discrete pre-AI wage is $w_1=z_1$ under (A1), whereas the paper's pre-AI wage $w(0)>0$ under $h<h_0$.

## AppliedModelingLib gates

The generated folder is intentionally unchanged in this audit. Its status reports not started, but PaperInterface.lean contains two Specs, and ProofInterface.lean and MainTheorems.lean contain no proof endpoints or implementations. Historical logs report 8315 and 8318 build jobs at different stages; neither proves Props. 5–6. Raw source-to-expanded-Spec audit has no entries.

Continue the actual upstream run at the pinned revision, preserve its generated tree and review the source-to-Spec correspondence:
1. Link $h_0$ correctly to economic primitives instead of a free threshold.
2. Establish source-consistent uniqueness: zero-mass occupation boundaries and the active domain of the matching function.
3. Check abundance (footnote 14), quantifier scope in Prop. 5, and avoid vacuous conditional equilibrium families.
4. Review feasibility, profit, matching, integration, total output and labor-income definitions.
5. Prove attainable exact endpoints without assuming conclusions. Preserve failures, regenerate status/audits upstream, run the prescribed fast check, and copy the entire generated folder as produced, honoring ignore rules.

## Remaining gates

Reproduce Python and sandbox Lean builds with CI at the new revision. Historical results are not independent new verification. Synchronize and recompile presentation/tutorial PDFs. Preserve original AI sessions, clearly distinguish summaries from verbatim transcripts, and document the student's reported model/deadline authorizations. Do not manufacture transcripts or audit results.

## Executed numerical regression, 2026-11-25

The rewritten endpoint module and six unittest cases were executed locally. All six passed. The candidate's positive boundary is 2/3. The bottom crossing uses bisection in candidate A when the pre-AI bottom wage is no greater than (2/3)(1-h); otherwise it uses the conditional AI-solver branch. The exercise does not establish the full post-AI equilibrium or universal threshold.

| h | pre-AI bottom wage | piecewise crossing | branch | naive AI-assisted crossing |
|---:|---:|---:|---|---:|
| 0.50 | 0.357044 | 0.714087 | AI solver (conditional) | 0.714087 |
| 0.74 | 0.172682 | 0.612875 | AI worker candidate | 0.664161 |

This is a numerical counterexample to applying the AI-assisted wage formula indiscriminately in the endpoint exercise. It is not a source-level Lean theorem. The discrete driver now rejects nonpositive sample counts and returns nonzero for property failures; the seeded 20,000 draws still require independent execution at the new revision.

See [LEAN_SOURCE_AUDIT.md](LEAN_SOURCE_AUDIT.md) for the frozen source-model proof and defect audit and the independent CI compilation.

## Independent final regression and upstream replay

[Run 45584755201](https://github.com/alejandroventuraventurameza-tech/ai-05-ide/actions/runs/45584755201) passed six Python regressions, the 20,000 seeded draws, all 12 discrete theorem endpoints and all 11 source-model audit endpoints. [Run 45584755327](https://github.com/alejandroventuraventurameza-tech/ai-05-ide/actions/runs/45584755327) separately passed the prescribed fast check (8315 jobs, exit 0) using the frozen folder and the compatible upstream pin. The initial updated Beamer and tutorial rendered successfully; visual inspection of every page prompted a clarification of the wage identity domain and two small layout repairs. The final documents must be rebuilt and visually reviewed at the new revision. The original paper's propositions remain not fully proved in Lean.

Final corrected document sources compiled without the final-log overfull-box/undefined-reference gate failing, and the 17 slides and 13 tutorial pages were visually inspected in [run 45586471082](https://github.com/alejandroventuraventurameza-tech/ai-05-ide/actions/runs/45586471082). The simultaneous validation run [45586470986](https://github.com/alejandroventuraventurameza-tech/ai-05-ide/actions/runs/45586470986) passed. The final PDF candidate is `0fedddd6db5883df1651b345505df15ebb4d552c`.
