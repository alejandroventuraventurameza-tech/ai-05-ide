# PROJECT_CONTEXT — ai-05-ide

## Assignment
Repository 5 of *Artificial Intelligence and Economic Modeling* (UP 2026-II, Prof. Alexander Quispe),
issue [#4](https://github.com/alexanderquispe/AI-Econ-Modeling/issues/4).
Template: [alexanderquispe/ai-01-aouad](https://github.com/alexanderquispe/ai-01-aouad).

**Paper.** Ide, E. & Talamàs, E. (2025). *Artificial Intelligence in the Knowledge Economy.*
Journal of Political Economy 133(12), 3762–3800. DOI 10.1086/737233 ·
[arXiv:2312.05481v11](https://arxiv.org/abs/2312.05481v11) (source version used everywhere).

**Focus.** Propositions 5 and 6, plus the discrete version of the model.
**Trap to address.** "Distributional effects are driven by AI autonomy, not capability" collapses a
two-dimensional taxonomy. Under what condition are there winners at the bottom — and is that
condition about autonomy or about capability?

## Required deliverables
1. `README.md` — one-page summary: question, agent problem, main result with all its conditions.
2. `prompts.md` — raw prompts and AI responses.
3. `hand/` — at least one photo of a handwritten derivation (intermediate-rigor proposition).
4. `presentation.tex` / `.pdf` — 20-minute Beamer deck, repository link on the title slide.
5. `lean/` — Lean 4 + Mathlib formalization (AppliedModelingLib workflow).

Value added: five reading questions (question, answer, argument, contribution, weaknesses),
a deep-dive tutorial, and extensions/simulations.

## Layout
| Path | Content |
|---|---|
| `paper/` | Paper PDF and primary sources |
| `extra/` | Tutorials, derivations, secondary sources, original assignment prompt |
| `hand/` | Photos of handwritten derivations |
| `lean/` | Lake project (`IdeTalamas`), Lean 4 + Mathlib |

## Lean conventions
- Toolchain `leanprover/lean4:v4.30.0-rc2`, Mathlib tag `v4.30.0-rc2` (same pin as AppliedModelingLib).
- Build from `lean/`: `lake exe cache get && lake build`.
- Forbidden: `sorry`, `admit`, `axiom`, `native_decide`.
- Keep `lean-toolchain`, `lakefile.toml`, `lake-manifest.json` and all `.lean` files tracked; `.lake/` is ignored.

## Workflow conventions
- Work happens on branch `analysis`; commits are made by Alejandro in GitHub Desktop.
- Conventional Commits (`feat:`, `docs:`, `build:`, `chore:`, `fix:`, `refactor:`, `test:`), one logical step per commit.
- Work section by section; no step is marked done until it is verified.
- Heavy commands (Lake builds, LaTeX compilation) are run by Alejandro in WSL to save tokens.
- Code, file names and code comments in English; explanations to Alejandro in Spanish.
- Folder lives on Windows (`C:\Users\ASUS\projects\ai-05-ide`) and is symlinked from WSL
  (`~/projects/ai-05-ide`).
