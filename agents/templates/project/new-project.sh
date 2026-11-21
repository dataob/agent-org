#!/bin/bash
# 새 프로젝트 폴더에 기본 틀을 복사한다. 이미 있는 파일은 덮어쓰지 않는다.
# 쓰는 법: ~/.agents/templates/project/new-project.sh ~/<폴더>
set -euo pipefail
[ $# -eq 1 ] || { echo "쓰는 법: $0 <프로젝트 폴더>"; exit 1; }
SRC=$(cd "$(dirname "$0")" && pwd)
DEST=$1
mkdir -p "$DEST/.agents/roles" "$DEST/.agents/skills" "$DEST/.claude"
for f in AGENTS.md CLAUDE.md .gitignore .agents/status.md .agents/glossary.md; do
  [ -e "$DEST/$f" ] || cp "$SRC/$f" "$DEST/$f"
done
[ -e "$DEST/.agents/roles/PM.md" ] || cp ~/.agents/roles/pm.md "$DEST/.agents/roles/PM.md"
[ -e "$DEST/.claude/skills" ] || ln -s ../.agents/skills "$DEST/.claude/skills"
echo "만듦: $DEST (AGENTS.md·PM.md의 <...> 자리를 채우세요)"
