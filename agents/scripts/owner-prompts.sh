#!/bin/bash
# 지난 N일(기본 7일) 동안 오너가 직접 입력한 메시지만 Claude Code 대화 기록에서 뽑는다.
# 다른 세션 메시지·도구 결과·시스템 주입·예약 작업 프롬프트는 뺀다.
# 출력: 한 줄에 하나, "<날짜 시각>\t<프로젝트 폴더>\t<메시지(줄바꿈은 ⏎)>"
# 쓰는 법: owner-prompts.sh [일수]          전체 목록
#         owner-prompts.sh [일수] --summary  짧은 말(20자 미만)은 횟수만, 긴 말은 전부(검토용)
set -euo pipefail
DAYS=${1:-7}
MODE=${2:-}
SINCE=$(date -u -v-"${DAYS}"d +%Y-%m-%dT%H:%M:%S 2>/dev/null || date -u -d "-${DAYS} days" +%Y-%m-%dT%H:%M:%S)
ROOT="$HOME/.claude/projects"
find "$ROOT" -name '*.jsonl' -not -path '*/subagents/*' -newermt "-${DAYS} days" 2>/dev/null | while read -r f; do
  proj=$(basename "$(dirname "$f")" | sed "s#^$(echo "$HOME" | tr / -)##; s#^-##; s#-#/#g")
  [ -z "$proj" ] && proj="~"
  jq -r --arg since "$SINCE" --arg p "$proj" '
    select(.type=="user" and (.isMeta|not) and (.timestamp >= $since)) |
    (.message.content | if type=="string" then . else ([.[]? | select(.type=="text") | .text] | join(" ")) end) as $t |
    select($t != "") |
    select($t | test("^(Another Claude session|<|\\[재시작|\\[오너 결정 전달|Caveat:|This session is being continued)") | not) |
    "\(.timestamp[0:16])\t\($p)\t\($t | gsub("\n"; " ⏎ "))"
  ' "$f" 2>/dev/null || true
done | sort > "${TMPDIR:-/tmp}/owner-prompts.$$"
if [ "$MODE" = "--summary" ]; then
  echo "## 짧은 말(20자 미만) 횟수"
  awk -F'\t' 'length($3)<20{print $3}' "${TMPDIR:-/tmp}/owner-prompts.$$" | sort | uniq -c | sort -rn | awk '$1>=2'
  echo; echo "## 긴 말(프로젝트별, 시간순)"
  awk -F'\t' 'length($3)>=20{if(length($3)>300)$3=substr($3,1,300)"…"; print $1"\t"$2"\t"$3}' "${TMPDIR:-/tmp}/owner-prompts.$$" | sort -t$'\t' -k2,2 -s
else
  cat "${TMPDIR:-/tmp}/owner-prompts.$$"
fi
rm -f "${TMPDIR:-/tmp}/owner-prompts.$$"
