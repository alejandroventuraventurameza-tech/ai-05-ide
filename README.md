# ai-05-ide — Ide & Talamàs (2025)

Repository: <https://github.com/alejandroventuraventurameza-tech/ai-05-ide>  
Course: Artificial Intelligence and Economic Modeling, UP 2026-II; [issue #4](https://github.com/alexanderquispe/AI-Econ-Modeling/issues/4).

**Source:** Ide, E. & Talamàs, E. (2025), *Artificial Intelligence in the Knowledge Economy*, JPE 133(12), 3762–3800, [DOI](https://doi.org/10.1086/737233). We use [arXiv:2312.05481v11](https://arxiv.org/abs/2312.05481v11).

## Question and agent's problem

Who gains from AI along the knowledge distribution, and how do capability and autonomy interact? Humans have knowledge $z\in[0,1]$ distributed according to $G$. A worker solves a uniformly distributed problem with probability $z$; a solver spends $h\in(0,1)$ units of time on each referral. The team size is $n(z)=1/[h(1-z)]$ for $z<1$. A firm choosing a human solver $s>z$ maximizes $n(z)[s-w(z)]-w(s)$; at an interior differentiable optimum $s=m(z)$, $w'(m(z))=n(z)$. AI agents have knowledge $a=z_{AI}$; autonomy permits production work as well as advice, whereas non-autonomous AI can only advise.

## Main results and conditions

Under the paper's standing assumptions (continuous strictly positive density, abundant production opportunities, competitive markets, $h<h_0$ so no independent producers before AI, $a\in[0,1)$, and compute abundant relative to human time):

**Autonomous AI (Props. 2 and 5, §§4–5.2).** Unique efficient equilibrium, compute rent $r^*=a$, and $w^*(a)=a<w(a)$. The winners lie at the extremes. The bottom winner set $B$ is nonempty iff $a>\bar a$, for a threshold $\bar a\in\operatorname{int}W$ (pre-AI workers). The top winner set $T$ is nonempty for every admissible $a$. For humans assisted by AI, $w^*(z)=a(1-1/n(z))$; thus $w^*(0)=a(1-h)$ when the bottom is in that regime. A universal closed form for the threshold is not claimed without establishing the equilibrium regime at the crossing.

**Non-autonomous AI (Prop. 6, §6).** Unique efficient equilibrium maximizing labor income, $r^\star=0$. If $a\le w(0)$, AI is unused and pre-AI occupations and wages are preserved. Otherwise only the least knowledgeable use AI, with nonempty assisted-worker, human-worker and human-solver sets. Total output is strictly below the autonomous regime. There is some $z\in(0,1]$ with $w^\star(z)\le w(z)$, strictly so if AI is used. In a neighborhood of zero, $w^\star(z)\ge\max\{w(z),w^*(z)\}$, strictly if AI is used; near one, $w^\star(z)\le w^*(z)$, strictly for $z\ne1$.

**The trap:** bottom gains require a capability threshold in both regimes; autonomy changes feasible occupations and the opportunity cost of compute. Do not infer that non-autonomous AI always creates strict winners or that every top human loses relative to no AI.

## Our work and evidence

- [Three-type derivation](extra/derivation/discrete-three-type.tex) and [handwritten proof](hand/discrete-derivation.pdf). Under (A0)–(A3), the discrete autonomous threshold is $z_1/[1-h(1-z_1)]$; if $a=z_2$ and the relevant gain/rent conditions hold, $w_1^*-w_1=(w_2-w_2^*)/n(z_1)$. The discrete model permits pre-AI independent producers and cannot reproduce Prop. 5's universal top-winner result. Setting $z_1=0$ does not recover the continuum threshold.
- [Python](code/): uniform-distribution endpoint calculations and seeded three-type property checks. Numerical evidence is not a general proof.
- [Lean sandbox](extra/lean-sandbox/): 12 theorem endpoints for discrete algebra, independently compiled and axiom-audited in [run 45580422981](https://github.com/alejandroventuraventurameza-tech/ai-05-ide/actions/runs/45580422981). Feasible allocations and source fidelity are not certified by those theorems.
- [AppliedModelingLib folder](lean/): source-facing Specs for Props. 5–6 compile according to the recorded session; proofs and semantic review remain open; five independent checked lemmas include a formal counterexample to the generated labor-income objective. See [Lean audit](extra/audit/LEAN_SOURCE_AUDIT.md). The generated status metadata is stale. This is a partial run, not a verified formalization of either proposition.
- [Presentation](presentation.tex), [tutorial](extra/tutorial/), [prompts](prompts.md), [checklist](REQUIREMENTS.md) and [source/validation audit](extra/audit/ECONOMIC_AUDIT.md). The existing deck/tutorial PDFs are prior versions pending editorial synchronization.

## Reproduce

    python3 code/equilibrium.py
    python3 code/discrete_check.py
    python3 -m unittest discover -s code -p 'test_*.py' -v
    cd extra/lean-sandbox && lake build

Prior agent configurations and deviations are preserved in prompts.md; the instructor's extension and authorization of GPT-6 with xhigh for continuation are reported by the student.
 
[GitHub Actions](https://github.com/alejandroventuraventurameza-tech/ai-05-ide/actions) independently checks the Python endpoint calculations and discrete Lean sandbox. Its results do not certify the official AppliedModelingLib Specs.
