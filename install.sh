#!/bin/bash
# agent-org를 홈 폴더에 연결한다. 원본은 이 저장소에 두고, 홈의 정해진 경로에는 링크만 만든다.
# - 이미 있는 파일(링크가 아닌 것)은 ~/.agents/backup/install-<시각>/으로 옮긴 뒤 링크한다.
# - 로컬 전용 파일(상태 문서·계정 목록·오너 줄임말)은 없을 때만 틀에서 복사한다.
# - 조직 홈(비서관 세션을 여는 폴더)은 기본이 홈(~)이다. 바꾸려면 ORG_HOME=<폴더> 로 실행한다.
#   정한 값은 ~/.agents/org-home에 저장되고, 다시 실행할 때 ORG_HOME을 주지 않으면 그대로 둔다.
# 쓰는 법: ~/agent-org/install.sh   또는   ORG_HOME=~/org ~/agent-org/install.sh   (여러 번 실행해도 된다)
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

ORG_HOME_FILE="$HOME/.agents/org-home"
if [ -n "${ORG_HOME:-}" ]; then
  mkdir -p "$ORG_HOME"
  (cd "$ORG_HOME" && pwd) > "$ORG_HOME_FILE"
elif [ ! -e "$ORG_HOME_FILE" ]; then
  echo "$HOME" > "$ORG_HOME_FILE"
fi
echo "조직 홈(비서관 폴더): $(cat "$ORG_HOME_FILE")"

echo "완료. 훅을 켜려면 README의 '훅 켜기'를 따라 ~/.claude/settings.json에 추가한다."
