---
name: org-setup-env
description: 새 컴퓨터·새 작업 환경에 agent-org 조직 지침을 설치한다(저장소 받기, install.sh로 홈에 링크, 로컬 기록 파일·비밀 값 파일·훅 설정). "새 환경 설정", "이 컴퓨터에도 조직 지침 깔아줘", agent-org를 처음 받을 때 쓴다.
---

# 새 환경에 조직 설정

agent-org 저장소의 일반 지침을 이 환경의 홈 폴더에 연결한다. 원본은 `~/agent-org`, 홈에는 링크만 둔다.

## 절차

1. **저장소 받기** (이미 있으면 `git -C ~/agent-org pull`)
   ```bash
   git clone https://github.com/<계정>/agent-org.git ~/agent-org
   ```
2. **설치 전 확인**: 홈에 이미 `~/.claude/CLAUDE.md`, `~/.agents/roles` 등이 있으면 오너에게 알린다. 설치하면 그 파일들은 `~/.agents/backup/install-<시각>/`으로 옮겨진다.
3. **설치**: 오너 확인 후 실행한다. 여러 번 실행해도 된다.
   ```bash
   ~/agent-org/install.sh
   ```
   - 링크: 전역 지침(`~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`), 플레이북, 코딩 원칙, 단어사전, `roles/`, `templates/`, 세션 정리 훅, 전역 스킬(`~/.agents/skills/<이름>`, `~/.claude/skills/<이름>`)
   - 없을 때만 틀에서 복사: `~/.agents/status.md`, `accounts.md`, `glossary-local.md`
4. **비밀 값 파일**: 오너가 직접 만든다. 에이전트는 값을 적거나 열지 않는다.
   ```bash
   mkdir -p ~/.config/secrets && touch ~/.config/secrets/env && chmod 600 ~/.config/secrets/env
   ```
5. **훅 켜기**: `~/.claude/settings.json`의 `hooks`에 아래를 합친다(기존 설정을 지우지 않는다). 설정 변경이므로 오너 확인 후 한다. 훅은 `jq`가 필요하고 macOS `stat`을 쓴다.
   ```json
   "hooks": {
     "UserPromptSubmit": [{"hooks": [{"type": "command", "command": "~/.agents/hooks/session-tidy.sh", "timeout": 10}]}],
     "SessionStart": [{"matcher": "compact|clear", "hooks": [{"type": "command", "command": "~/.agents/hooks/session-tidy.sh", "timeout": 10}]}]
   }
   ```
6. **개인 기록 저장소**(선택): 홈을 원격 없는 git 저장소로 두고 `~/.agents/status.md`, `accounts.md`, `glossary-local.md`만 추적한다.
7. **확인**: `ls -l ~/.claude/CLAUDE.md`가 `~/agent-org/global/CLAUDE.md`를 가리키는지, 훅이 오류 없이 도는지 본다. 결과를 오너에게 짧게 보고한다.

## 업데이트
- 지침이 바뀌면 `git -C ~/agent-org pull`. 새 전역 스킬이 생겼으면 `install.sh`를 다시 실행해 링크를 만든다.
