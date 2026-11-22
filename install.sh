#!/bin/bash
# agent-org를 홈 폴더에 연결한다. 원본은 이 저장소에 두고, 홈의 정해진 경로에는 링크만 만든다.
# - 이미 있는 파일(링크가 아닌 것)은 ~/.agents/backup/install-<시각>/으로 옮긴 뒤 링크한다.
# - 로컬 전용 파일(상태 문서·계정 목록·오너 줄임말)은 없을 때만 틀에서 복사한다.
# 쓰는 법: ~/agent-org/install.sh   (여러 번 실행해도 된다)
set -euo pipefail
REPO=$(cd "$(dirname "$0")" && pwd)
BACKUP="$HOME/.agents/backup/install-$(date +%Y%m%d-%H%M%S)"

link() {  # link <저장소 안 원본> <홈 경로>
  local src="$REPO/$1" dst="$HOME/$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then return; fi
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mkdir -p "$BACKUP/$(dirname "$2")"
    mv "$dst" "$BACKUP/$2"
    echo "백업: ~/$2"
  fi
  ln -s "$src" "$dst"
  echo "링크: ~/$2 -> $1"
}

link global/CLAUDE.md            .claude/CLAUDE.md
link global/CLAUDE.md            .codex/AGENTS.md
link agents/pm-playbook.md       .agents/pm-playbook.md
link agents/coding-principles.md .agents/coding-principles.md
link agents/glossary.md          .agents/glossary.md
link agents/operations.md        .agents/operations.md
link agents/roles                .agents/roles
link agents/templates            .agents/templates
link agents/hooks/session-tidy.sh .agents/hooks/session-tidy.sh

for d in "$REPO"/agents/skills/*/; do
  [ -d "$d" ] || continue
  n=$(basename "$d")
  link "agents/skills/$n" ".agents/skills/$n"
  link "agents/skills/$n" ".claude/skills/$n"
done

for f in status.md accounts.md glossary-local.md environment.md; do
  if [ ! -e "$HOME/.agents/$f" ]; then
    cp "$REPO/agents/templates/$f" "$HOME/.agents/$f"
    echo "만듦: ~/.agents/$f (틀에서 복사)"
  fi
done

echo "완료. 훅을 켜려면 README의 '훅 켜기'를 따라 ~/.claude/settings.json에 추가한다."
