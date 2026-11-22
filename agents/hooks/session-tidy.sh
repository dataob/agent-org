#!/bin/bash
# 세션 정리 알림 훅 (전역 지침 2절 "세션 정리")
# - UserPromptSubmit: 대화 기록 파일이 기준(STEP)의 배수를 새로 넘을 때마다 한 번 알림
# - SessionStart(compact): 자동 압축 직후 알림
# - SessionStart(clear): 대화를 비운 직후, 고유 지침·상태 문서를 먼저 읽으라는 안내
# - SessionStart(startup): 새 세션을 연 직후, 같은 읽기 안내 + PM은 실무를 담당에게 배정한다는 안내
STEP=${SESSION_TIDY_STEP_BYTES:-2500000}
STATE=~/.agents/hooks/.state
input=$(cat)
event=$(printf '%s' "$input" | jq -r '.hook_event_name // empty')
sid=$(printf '%s' "$input" | jq -r '.session_id // empty')
tp=$(printf '%s' "$input" | jq -r '.transcript_path // empty')
size=0
[ -n "$tp" ] && [ -f "$tp" ] && size=$(stat -f %z "$tp" 2>/dev/null || echo 0)
mb=$(awk "BEGIN{printf \"%.1f\", $size/1000000}")
msg="[세션 정리 알림] 이 대화가 길어졌다(대화 기록 약 ${mb}MB). 전역 지침 2절 '세션 정리'에 따라, 지금 하던 작업 단위를 마무리한 뒤 ① 상태 문서(프로젝트는 .agents/status.md 또는 PROJECT_STATUS.md, 홈 폴더 비서관은 ~/.agents/status.md)를 갱신하고 ② 인수인계 요약을 남기고 ③ 이 세션을 스스로 비워라(앱의 세션 비우기 기능 clear_session, 대상 \"self\"; 도구가 목록에 없으면 ToolSearch로 불러온다). 비우기 직전 오너에게 한 줄로 알린다. 막히면(Remote Control 켜짐, 승인 거부 등) 오너에게 이 세션 입력창에서 /clear를 안내한다. 새 세션은 만들지 않는다(세션 목록 유지). 대화 원본은 남는다."
source=$(printf '%s' "$input" | jq -r '.source // empty')
if [ "$event" = "SessionStart" ] && { [ "$source" = "clear" ] || [ "$source" = "startup" ]; }; then
  cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')
  status=""
  if [ "$cwd" = "$HOME" ]; then
    status="$HOME/.agents/status.md"
  else
    # 세션 폴더 → 바로 아래 폴더(예: ~/프로젝트/하위폴더) → 상위 폴더 순서로 찾는다(홈은 제외)
    for f in "$cwd/.agents/status.md" "$cwd/PROJECT_STATUS.md" "$cwd"/*/.agents/status.md "$cwd"/*/PROJECT_STATUS.md; do
      [ -f "$f" ] && { status="$f"; break; }
    done
    p=$(dirname "$cwd")
    if [ -z "$status" ] && [ "$p" != "$HOME" ]; then
      for f in "$p/.agents/status.md" "$p/PROJECT_STATUS.md"; do
        [ -f "$f" ] && { status="$f"; break; }
      done
    fi
  fi
  [ -z "$status" ] && status="이 프로젝트의 상태 문서(.agents/status.md 또는 PROJECT_STATUS.md)"
  if [ "$source" = "startup" ]; then
    msg="[세션 시작 안내] 새 세션이다. 첫 답을 하기 전에 먼저 ① 이 세션의 역할을 정하고 그 고유 지침(홈 폴더는 비서관 ~/.agents/roles/secretary.md. 제목이 '00_… PM'이거나 오너가 PM이라고 명시했으면 PM: .agents/roles/PM.md. 다른 세션이 시작했거나 지시서가 있거나 제목이 'NN_…'·'임시_…'면 담당: 지시서의 \"시작 때 읽을 것\" 또는 .agents/roles/<담당>.md. 프로젝트 폴더당 PM은 한 명이고 담당은 PM 대행을 하지 않는다. 판단이 안 되면 오너에게 묻는다)과 ② 상태 문서 ${status} 를 읽는다. PM은 전역 지침 1절대로 코드 작성·수정과 수집·배포·예약 같은 실행을 직접 하지 않고 담당에게 배정한다(오너가 '직접 해'라고 한 경우만 예외)."
    jq -n --arg c "$msg" '{systemMessage:"세션 시작 안내를 에이전트에 전달했습니다.", hookSpecificOutput:{hookEventName:"SessionStart", additionalContext:$c}}'
    exit 0
  fi
  msg="[세션 재시작 안내] 오너가 세션 정리를 위해 이 세션의 대화를 비웠다(/clear). 이전 대화는 없다. 답하기 전에 먼저 ① 이 세션 제목에 맞는 고유 지침(프로젝트 .agents/roles/, 홈 폴더 비서관은 ~/.agents/roles/secretary.md)과 ② 상태 문서 ${status} 를 읽고, 그 내용으로 이어간다. 오너의 첫 메시지가 인사(\"안녕\" 등)나 짧은 말이어도 인사만 하지 말고 짧은 업무 브리핑으로 답한다: ① 현재 상태 1~2줄 ② 오너 결정 필요·확인할 것 ③ 다음 할 일 제안, 끝에 \"어떤 것부터 할까요?\". 오너가 구체적인 요청을 했으면 브리핑 없이 그 요청부터 처리한다."
  jq -n --arg c "$msg" '{systemMessage:"세션 재시작 안내를 에이전트에 전달했습니다.", hookSpecificOutput:{hookEventName:"SessionStart", additionalContext:$c}}'
  exit 0
fi
if [ "$event" = "SessionStart" ]; then
  msg="[세션 정리 알림] 방금 대화가 자동 압축됐다. ${msg#*\] }"
  out_event=SessionStart
else
  [ -z "$sid" ] && exit 0
  level=$(( size / STEP ))
  [ "$level" -lt 1 ] && exit 0
  mkdir -p "$STATE"
  last=$(cat "$STATE/$sid" 2>/dev/null || echo 0)
  [ "$level" -le "$last" ] && exit 0
  echo "$level" > "$STATE/$sid"
  out_event=UserPromptSubmit
fi
jq -n --arg e "$out_event" --arg c "$msg" --arg s "세션 정리 알림을 에이전트에 전달했습니다(대화 기록 약 ${mb}MB)." \
  '{systemMessage:$s, hookSpecificOutput:{hookEventName:$e, additionalContext:$c}}'
