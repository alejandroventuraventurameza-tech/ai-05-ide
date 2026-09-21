# ai-05-ide — Ide & Talamàs (2025), *Artificial Intelligence in the Knowledge Economy*

Weekly repository 5 for *Artificial Intelligence and Economic Modeling* (UP 2026-II), issue
[#4](https://github.com/alexanderquispe/AI-Econ-Modeling/issues/4).

**Paper.** Ide, E. & Talamàs, E. (2025). *Artificial Intelligence in the Knowledge Economy.*
Journal of Political Economy 133(12), 3762–3800. DOI [10.1086/737233](https://doi.org/10.1086/737233).
**Version read: arXiv:2312.05481v11 (25 February 2025, 35 pp.)**, which is the version the Lean run pins.

---

## The question

When a technology can do cognitive work, who gains and who loses along the knowledge distribution —
and does the answer depend on how *capable* the AI is, or on whether it can work *autonomously*?

The paper's contribution is to answer this inside an organization: AI does not just replace tasks, it
changes **who works with whom**, and the wage effects run through that reassignment.

## The agent's problem

A unit mass of humans with knowledge $z\in[0,1]$, distributed according to $G$. Each production
opportunity carries a problem of difficulty $x\sim U[0,1]$; knowledge $z$ is the probability of solving
it alone. Firms have at most two layers. In a two-layer firm each unsolved problem costs the solver
$h\in(0,1)$ units of time, so a solver supervises

$$n(z)=\frac{1}{h(1-z)}$$

workers of knowledge $z$. A firm choosing a solver $s$ for a team of workers $z$ solves

$$\max_{s}\ n(z)\,[\,s-w(z)\,]-w(s),$$

whose first-order condition, $w'(m(z))=n(z)$, says that **a solver's marginal wage is the size of the
team she supervises**. AI turns compute into agents of knowledge $z_{AI}$ that are perfect substitutes
for a human of that knowledge; compute is abundant relative to human time.

## The main result, with its conditions

Under $G$ with continuous, strictly positive density, $h<h_0$ (no independent producers before AI),
$z_{AI}\in[0,1)$ and compute abundant relative to time:

**Autonomous AI (Propositions 2 and 5).** The equilibrium is unique and efficient, the rental rate of
compute is $r^{*}=z_{AI}$, and the human with knowledge $z_{AI}$ always loses. Winners are located at
the two extremes of the distribution. There are **always winners at the top**; there are winners at the
bottom **if and only if $z_{AI}>\bar z_{AI}$**, with $\bar z_{AI}$ in the interior of the pre-AI worker
set. Two closed forms carry the result: the top human earns $w^{*}(1)=n(z_{AI})(1-z_{AI})=1/h$,
independently of $z_{AI}$, and the bottom human, once AI supervises him, earns
$w^{*}(0)=z_{AI}(1-h)$.

**Non-autonomous AI (Proposition 6).** The equilibrium is unique and efficient, $r^{\star}=0$, and AI
is used **iff $z_{AI}>w(0)$**. Then total output is strictly lower than with autonomous AI; the least
knowledgeable are better off than under either autonomous AI or no AI; the most knowledgeable are worse
off than under autonomous AI.

### This week's trap

The one-line gloss — *"the distributional effect is driven by AI autonomy, not capability"* — collapses
a two-dimensional taxonomy. In **both** regimes the existence of winners at the bottom is a
**capability** threshold:

| | autonomous AI | non-autonomous AI |
|---|---|---|
| rental rate of compute | $r^{*}=z_{AI}$ | $r^{\star}=0$ |
| wage at the bottom | $z_{AI}(1-h)$ | $z_{AI}$ |
| winners at the bottom | iff $z_{AI}>w(0)/(1-h)$ | iff $z_{AI}>w(0)$ |
| winners at the top | always | not necessarily |
| total output | higher | lower |

Autonomy does not decide *whether* there are winners at the bottom; it moves the threshold by the
factor $1/(1-h)$ — the opportunity cost of the AI — and scales the size of the gain. Removing autonomy
creates no winners at the bottom when $z_{AI}\le w(0)$, because then the AI is not used at all. What
autonomy does decide is total output, the fate of the top, and how much the bottom gains.

---

## What this repository adds

- **`extra/tutorial/`** — a four-part walk through the model (question, pre-AI benchmark, autonomous AI,
  Propositions 5 and 6), with the uniform case solved in closed form. Our $w^{*}(0)$ and $w^{*}(1)$
  reproduce the values in Figures 4 and 5 of the paper.
- **`extra/derivation/`** — a **discrete three-type version** of the model, stated as a competitive
  equilibrium and proved: the equilibrium wages, the two capability thresholds, and an exact identity,
  $w_1^{*}-w_1=(w_2-w_2^{*})/n(z_1)$, saying that the rent lost by the automated type is shared among
  the workers it used to supervise. It also proves where finite types *cannot* reproduce the paper.
- **`code/`** — an equilibrium solver for the continuum (standard library only) and a randomized
  property test that checks, over 20 000 draws of primitives, that no admissible firm configuration
  earns positive profit and that every corollary holds.
- **`extra/lean-sandbox/`** — our own Lean 4 + Mathlib formalization of the discrete results
  (`IdeTalamas/Discrete.lean`), building with exit code 0 and with an axiom audit showing no `sorryAx`.
- **`lean/`** — the AppliedModelingLib paper folder, copied exactly as generated.
- **`hand/`** — the derivation written by hand.

## Reproducing

```bash
python3 code/equilibrium.py            # continuum equilibria and thresholds
python3 code/discrete_check.py         # randomized property test
cd extra/lean-sandbox && lake build    # Lean formalization + axiom audit
cd extra/tutorial   && latexmk -pdf tutorial-ide-talamas.tex
cd extra/derivation && latexmk -pdf discrete-three-type.tex
```

## What Lean verifies, and what it does not

Lean checks that the discrete statements follow from the stated hypotheses: the monotonicity lemma
behind the result on the most knowledgeable type, the capability threshold as an equivalence, the
share-effect identity, and the no-positive-profit condition for each admissible firm configuration.
It does **not** check that the discrete model is a faithful translation of the paper, nor the two
results that are proved on paper only: that pure firm configurations are without loss of generality,
and the existence of a feasible allocation. Those limits are stated in the derivation itself.
