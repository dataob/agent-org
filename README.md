# agent-org

AI 에이전트(Claude Code·Codex) 여러 개를 **하나의 조직처럼** 운영하기 위한 일반 지침·틀·전역 스킬 모음이다. 어떤 프로젝트에도 묶이지 않은 것만 담는다. 이 저장소를 받아 `install.sh`를 실행하면 누구나 같은 구조로 자기 조직을 운영할 수 있다. 업무 중 일반적으로 쓸 만한 지침이나 스킬이 생기면 일반화해 계속 더해 간다.

---

## 1. 조직 구조

```text
오너(사용자) ── 최종 결정권자
 ├─ 비서관 ──── 조직 홈(기본 ~)에서 연 세션. 전역 지침·틀·전역 스킬 관리, 프로젝트 간 조직 검토
 └─ PM ──────── 프로젝트 폴더마다 1명. 업무 정리·배정·검증·보고
      └─ 담당 ── 한 분야의 실무 세션(상설 또는 임시)
```

- **에이전트** = 고유 지침을 가진 채팅창(세션) 하나. 세션을 어느 폴더에서 여느냐로 역할이 정해진다.
- **오너 승인 필요**: 돈·운영에 영향을 주는 일, 되돌릴 수 없는 일(삭제·발행·배포), 새 규칙, 조직 확장. 커밋·푸시는 요청받을 때만.
- **예외 보고**: 정상 완료는 한 줄, 문제·결정 필요·확인 못 한 것이 있을 때만 자세히.
- **오너 결정 전달**: 다른 세션에 오너 결정을 전할 땐 이 표시를 붙인다. 없으면 승인이 아니다.
- **요청 의도 확인**: 무언가 바뀌는 요청은 "이렇게 이해했어요 → 맞나요?"로 한 번 확인한 뒤 실행.
- **세션 정리**: 대화가 길어지면 상태 문서를 갱신하고 같은 세션을 비운다. 새 세션은 상태 문서만 읽고 이어간다.

---

## 2. 저장소와 홈 폴더의 관계

원본은 이 저장소(`~/agent-org`)에 있고, 에이전트가 읽는 홈 경로에는 **링크**만 둔다. 그래서 지침을 고치면 모든 세션에 바로 적용되고, 개인 기록은 저장소에 섞이지 않는다.

| 홈 경로 (에이전트가 읽는 곳) | 원본 (이 저장소) |
|---|---|
| `~/.claude/CLAUDE.md` | `global/CLAUDE.md` |
| `~/.codex/AGENTS.md` | `global/CLAUDE.md` (Codex도 같은 원본) |
| `~/.agents/pm-playbook.md` | `agents/pm-playbook.md` |
| `~/.agents/coding-principles.md` | `agents/coding-principles.md` |
| `~/.agents/glossary.md` | `agents/glossary.md` |
| `~/.agents/roles/` | `agents/roles/` |
| `~/.agents/templates/` | `agents/templates/` |
| `~/.agents/hooks/session-tidy.sh` | `agents/hooks/session-tidy.sh` |
| `~/.agents/skills/<이름>`, `~/.claude/skills/<이름>` | `agents/skills/<이름>/` |

홈에만 있는 **개인 기록**(이 저장소에 올리지 않음): `~/.agents/status.md`(비서관 상태 문서), `~/.agents/accounts.md`(키 위치 목록), `~/.agents/glossary-local.md`(오너 줄임말), `~/.agents/environment.md`(이 컴퓨터의 상시 가동·재부팅·예약 작업 설명), `~/.config/secrets/env`(비밀 값). 홈 폴더를 원격 없는 git 저장소로 두고 이 기록만 따로 추적해도 된다.

---

## 3. 폴더·파일 설명

```text
agent-org/
├── README.md                    이 문서
├── install.sh                   홈 폴더에 링크를 만드는 설치 스크립트
├── global/
│   └── CLAUDE.md                전역 지침 (Claude Code·Codex 공용 원본)
└── agents/
    ├── README.md                agents 폴더 안내
    ├── pm-playbook.md           조직 성장·정례 검토·이름 규칙
    ├── coding-principles.md     코드 작업 전에 읽는 원칙
    ├── glossary.md              공통 단어사전
    ├── roles/                   역할별 고유 지침 틀
    │   ├── secretary.md         비서관
    │   ├── pm.md                PM
    │   └── member.md            담당
    ├── hooks/
    │   └── session-tidy.sh      세션 정리 알림 훅
    ├── skills/                  전역 스킬
    │   ├── org-new-project/     새 프로젝트 만들기
    │   └── org-setup-env/       새 환경에 조직 설정
    └── templates/               새 환경·새 프로젝트용 빈 틀
        ├── status.md            비서관 상태 문서 틀
        ├── accounts.md          계정·키 위치 목록 틀
        ├── glossary-local.md    오너 줄임말 틀
        ├── environment.md       작업 환경 설명 틀
        └── project/             새 프로젝트 폴더 틀
            ├── new-project.sh   틀을 프로젝트 폴더에 복사하는 스크립트
            ├── AGENTS.md        프로젝트 지침 틀
            ├── CLAUDE.md        "@AGENTS.md" 한 줄
            ├── .gitignore       .env 등 제외
            └── .agents/
                ├── status.md    프로젝트 상태 문서 틀
                └── glossary.md  프로젝트 단어사전 틀
```

### `install.sh`
홈 폴더의 정해진 경로에 이 저장소 원본으로 가는 링크를 만든다.
- 이미 있는 파일(링크가 아닌 것)은 `~/.agents/backup/install-<시각>/`으로 옮긴 뒤 링크한다.
- 개인 기록 파일 4개는 없을 때만 틀에서 복사한다.
- 조직 홈(비서관 폴더)을 `ORG_HOME`으로 정하면 `~/.agents/org-home`에 저장한다. 기록은 조직 홈과 상관없이 `~/.agents`에 둔다.
- 여러 번 실행해도 된다. 새 전역 스킬을 추가했을 때도 다시 실행한다.

### `global/CLAUDE.md` — 전역 지침
모든 에이전트가 항상 읽는 기본 규칙. 프로젝트 지침과 충돌하면 프로젝트 지침이 이긴다.

| 절 | 누가 따르나 | 내용 |
|---|---|---|
| 1. 조직 운영 | 모든 에이전트 | 오너·비서관·PM·담당의 권한과 일, 배정·예외 보고·감리·작업 환경·일반 지침 모으기·단어사전·비밀 값 규칙, **지시서 틀**과 **완료 보고 틀** |
| 2. 토큰 절약 | 모든 에이전트 | 필요한 것만 읽기, 계획 먼저, 작게 나눠 진행, 상태 문서 유지, 세션 정리 절차 |
| 3. 요청 의도 확인 | 오너와 대화하는 에이전트(보통 PM) | 오타·중의성을 정리해 한 번 되묻고 실행 |
| 4. 코딩 원칙 | 코드를 다루는 에이전트 | `coding-principles.md`를 먼저 읽으라는 안내 |

### `agents/pm-playbook.md` — 플레이북
평소에는 읽지 않고 **담당 채용·분할·프로젝트 분리를 판단할 때만** 읽는다. 용어와 구조, 고유 지침 작성법, 권한, PM의 일 순서, 담당 역할 4종, 지시서 원칙, 검증과 보고, 성장 단계(담당 채용 → 분할 → 프로젝트 분리), 이름 규칙, 토큰 절감 체크리스트.

### `agents/coding-principles.md` — 코딩 원칙
코드를 쓰거나 고치기 전에 읽는다. 코딩 전에 생각하기, 단순함 우선, 필요한 곳만 고치기, 목표 중심 실행.

### `agents/glossary.md` — 공통 단어사전
조직·운영 용어(오너, 비서관, PM, 담당, 감리, 지시서, 예외 보고, 상태 문서, agent-org 등)와 프로젝트 단어사전 틀. 사전은 세 층이고 겹치면 프로젝트 사전이 우선한다.

| 파일 | 내용 | 관리 | 위치 |
|---|---|---|---|
| `~/.agents/glossary.md` | 공통 용어 | 비서관 | 이 저장소 |
| `~/.agents/glossary-local.md` | 오너 줄임말(프로젝트 이름 등) | 비서관 | 홈(개인) |
| `<프로젝트>/.agents/glossary.md` | 그 프로젝트에서만 쓰는 말 | PM | 프로젝트 |

### `agents/roles/` — 고유 지침 틀
에이전트가 "누구인지"를 적는 파일. 공통 항목은 **소속·보고 대상, 맡은 일, 하지 않는 것, 절차, 쓰는 스킬, 보고 틀**.

| 파일 | 쓰는 법 |
|---|---|
| `secretary.md` | 조직 홈 세션(비서관)이 그대로 읽는다. 두 저장소 관리, agent-org에 올리는 기준과 절차, 프로젝트 지침 수정 절차 |
| `pm.md` | 새 프로젝트의 `.agents/roles/PM.md`로 복사해 `< >`를 채운다 |
| `member.md` | 담당을 만들 때 `<프로젝트>/.agents/roles/<이름>.md`로 복사해 채운다 |

### `agents/hooks/session-tidy.sh` — 세션 정리 훅
Claude Code 훅으로 등록해 쓴다.

| 때 | 하는 일 |
|---|---|
| 대화 기록이 2.5MB를 넘을 때마다 | "상태 문서 갱신 → 인수인계 → 세션 비우기" 알림 |
| 자동 압축 직후 | 같은 알림 |
| 세션을 비운 직후 | 고유 지침과 상태 문서를 먼저 읽고 업무 브리핑으로 이어가라는 안내 |

`jq`가 필요하고 파일 크기는 macOS `stat -f %z`로 읽는다(리눅스는 `stat -c %s`). 기준 크기는 `SESSION_TIDY_STEP_BYTES`로 바꾼다. 세션별 기록은 홈의 `~/.agents/hooks/.state/`에 쌓인다.

### `agents/skills/` — 전역 스킬
일하는 "절차". 지침(누구인지)과 섞지 않는다. 필요할 때만 읽힌다.

| 스킬 | 쓰는 때 |
|---|---|
| `org-new-project` | 새 프로젝트 폴더를 조직 규칙대로 만들고 등록할 때 |
| `org-setup-env` | 새 컴퓨터·새 환경에 이 저장소를 설치할 때 |

### `agents/templates/` — 틀
환경마다 내용이 달라 저장소에 올리지 않는 파일의 빈 틀. `status.md`·`accounts.md`·`glossary-local.md`·`environment.md`는 `install.sh`가 홈에 복사하고, `project/`는 `new-project.sh`로 새 프로젝트에 복사한다.

---

## 4. 프로젝트 폴더 구조

```text
<프로젝트>/
├── AGENTS.md            프로젝트 지침 원본: 목표, 오너 결정, 금지, 폴더, 에이전트 명단
├── CLAUDE.md            "@AGENTS.md" 한 줄 (Claude Code가 AGENTS.md를 읽게 함)
├── .gitignore           .env 등 비밀 값 제외
├── .claude/
│   └── skills  →  ../.agents/skills   (링크)
└── .agents/
    ├── status.md        상태 문서: 현재 단계, 결정 사항, 남은 일, 인수인계
    ├── glossary.md      프로젝트 단어사전
    ├── roles/           고유 지침: PM.md, 담당마다 <이름>.md
    └── skills/          프로젝트 스킬 원본 (새 스킬은 여기에만 만든다)
```

```bash
~/.agents/templates/project/new-project.sh ~/<프로젝트 폴더>
```

---

## 5. 새 환경에서 시작하기

1. 받기
   ```bash
   git clone https://github.com/<계정>/agent-org.git ~/agent-org
   ```
2. 설치 (기존 파일은 자동 백업)
   ```bash
   ~/agent-org/install.sh
   ```
   비서관 세션을 홈(`~`)이 아닌 폴더에서 열려면 조직 홈을 정해 설치한다. 값은 `~/.agents/org-home`에 저장되고, 바꿀 때도 같은 명령을 다시 실행한다.
   ```bash
   ORG_HOME=~/org ~/agent-org/install.sh
   ```
3. 비밀 값 파일 (오너만 편집)
   ```bash
   mkdir -p ~/.config/secrets && touch ~/.config/secrets/env && chmod 600 ~/.config/secrets/env
   ```
4. 훅 켜기 — `~/.claude/settings.json`의 `hooks`에 합친다.
   ```json
   "hooks": {
     "UserPromptSubmit": [{"hooks": [{"type": "command", "command": "~/.agents/hooks/session-tidy.sh", "timeout": 10}]}],
     "SessionStart": [{"matcher": "startup|compact|clear", "hooks": [{"type": "command", "command": "~/.agents/hooks/session-tidy.sh", "timeout": 10}]}]
   }
   ```
5. 조직 홈 세션은 비서관, 프로젝트 폴더의 `00_<프로젝트> PM` 세션은 PM, 그 밖의 세션은 담당으로 동작한다(프로젝트 폴더당 PM은 한 명).

자세한 절차는 전역 스킬 `org-setup-env`에 있다. 업데이트는 `git -C ~/agent-org pull` 후 필요하면 `install.sh`를 다시 실행한다.

### 윈도우에서 설치할 때

스크립트는 macOS 기준이다. 윈도우에서는 **Git Bash**에서 아래처럼 바꿔 실행한다(`~`는 `C:\Users\<이름>`).

| 항목 | 바꿀 것 |
|---|---|
| 링크 | 설정 → 개발자 모드를 켜고, 실행 전에 `export MSYS=winsymlinks:nativestrict`. 안 하면 링크 대신 **사본**이 생겨 저장소 수정이 반영되지 않는다 |
| 줄바꿈 | 받기 전에 `git config --global core.autocrlf input`. `.sh`가 CRLF로 바뀌면 bash가 실행하지 못한다 |
| 훅 | `jq` 설치(`winget install jqlang.jq`). `session-tidy.sh`의 `stat -f %z`를 `stat -c %s`로 바꾼다(안 바꾸면 크기 알림이 조용히 꺼진다). `settings.json`의 명령은 `bash ~/.agents/hooks/session-tidy.sh`로 쓴다 |
| 비밀 값 파일 | `chmod 600`은 효과가 없다. 파일 속성 → 보안에서 본인 계정만 읽게 한다 |
| 예약 작업 | `launchd`(`~/Library/LaunchAgents`) 대신 작업 스케줄러를 쓴다. `environment.md`도 그 기준으로 채운다 |

---

## 6. 이 저장소에 더하는 기준

- 어떤 프로젝트·환경에도 묶이지 않을 것. 프로젝트 이름·경로·키 위치·계정·개인 기록이 없을 것.
- 고유 이름은 `<프로젝트>` 같은 자리 표시로 바꾼다.
- 올리기 전에 개인 정보를 검사하고, 커밋 제목은 바꾼 폴더·파일의 성격이 드러나게 쓴다(GitHub 파일 목록에 그대로 보인다).
- API 키·토큰·비밀번호는 절대 두지 않는다.
