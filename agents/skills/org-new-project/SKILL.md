---
name: org-new-project
description: 에이전트 조직 규칙에 맞는 새 프로젝트 폴더를 만든다(AGENTS.md·CLAUDE.md·상태 문서·PM 고유 지침·스킬 링크). "새 프로젝트 만들어줘", "프로젝트 틀 잡아줘", 새 프로젝트를 조직에 등록할 때 쓴다.
---

# 새 프로젝트 만들기

전역 지침 1절의 구조(PM → 담당, Claude·Codex 공용 원본)대로 새 프로젝트 폴더를 준비한다. 주로 비서관이나 새 프로젝트의 PM이 쓴다.

## 절차

1. **오너에게 확인할 것** (전역 지침 3절, 한 번에 묻는다)
   - 프로젝트 폴더(`~/<폴더>`)와 이름
   - 목표 한두 문장, 범위 밖인 것
   - PM 세션 이름(기본 `00_<이름> PM`)
   - git 사용 여부
2. **틀 복사**: 이미 있는 파일은 덮어쓰지 않는다.
   ```bash
   ~/.agents/templates/project/new-project.sh ~/<폴더>
   ```
   만들어지는 것: `AGENTS.md`, `CLAUDE.md`(`@AGENTS.md`), `.gitignore`, `.agents/status.md`, `.agents/glossary.md`, `.agents/roles/PM.md`, `.agents/skills/`, `.claude/skills` → `../.agents/skills` 링크
3. **채우기**: `AGENTS.md`와 `.agents/roles/PM.md`의 `< >` 자리를 오너 답으로 채운다. 오너가 정한 것은 "오너 결정(날짜)"로 적는다. 정하지 않은 것은 비워 두고 상태 문서 "남은 일"에 적는다.
4. **git**(오너가 원할 때만): `git init`. `.env`가 제외되는지 `git check-ignore .env`로 확인한다.
5. **등록**: 비서관 상태 문서(`~/.agents/status.md`)의 프로젝트 현황 표에 한 줄 추가하고, 오너 줄임말이 있으면 `~/.agents/glossary-local.md`에 적는다.
6. **보고**: 만든 파일, 채우지 못한 자리, 오너가 할 일(PM 세션 열기·이름 붙이기, 사이드바 정리)을 짧게 보고한다.

## 하지 않는 것
- 프로젝트 실무(설계·코드)는 시작하지 않는다. PM 몫이다.
- 비밀 값 파일(`.env`)을 만들거나 값을 적지 않는다.
