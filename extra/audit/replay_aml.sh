#!/usr/bin/env bash
# Recheck the *preserved* student output on a compatible public historical
# revision. This is a replay, NOT the original checkout or a new agent run.
set -euo pipefail
root="$(cd "$(dirname "$0")/../.." && pwd)"
upstream="$(cd "$1" && pwd)"
pin=2db7d108cd3a2cb10148974bb2a77856e7d87428
paper=IT25KnowledgeEconomy
cd "$upstream"
test "$(git rev-parse HEAD)" = "$pin"
test ! -e "papers/$paper"
test ! -e "papers/$paper.lean"
printf 'Upstream replay revision: %s\n' "$pin"
printf 'Student snapshot: %s\n' "$(git -C "$root" rev-parse HEAD)"
cp -a "$root/lean" "papers/$paper"
diff -qr "$root/lean" "papers/$paper"
# The historical root module and lakefile registration are absent from the
# weekly-repository export. Reconstruct only those integration shims.
printf 'import %s.PaperInterface\nimport %s.ProofInterface\nimport %s.MainTheorems\n' \
  "$paper" "$paper" "$paper" > "papers/$paper.lean"
printf '\n[[lean_lib]]\nname = "%s"\nsrcDir = "papers"\n' "$paper" >> lakefile.toml
lake exe cache get
set +e
python3 scripts/paper_contribution.py check "$paper" --fast
rc=$?
set -e
printf 'PAPER_CONTRIBUTION_FAST_EXIT=%s\n' "$rc"
diff -qr "$root/lean" "papers/$paper"
exit "$rc"
