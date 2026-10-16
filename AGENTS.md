# Agent Guidelines

## Core Rules

- **Zero Emoji**: Never include emojis in document content, git commit messages, or agent responses.
- **No PDF Scripts**: Never use Python, uv, or external scripts to process PDFs. Inspect PDFs directly via `Read`.
- **Language**:
  - **Study Notes (`week01` - `week13`)**: Use Thai as the primary language, preserving English technical terms in parentheses, e.g., "งบประมาณความผิดพลาด (Error Budget)".
  - **Operational Forms & MOPs (`forms/`)**: Use English technical terms directly without redundant Thai translations in parentheses (e.g., CMM, Compute Node, ToR Switch) for operational clarity. Never wrap slot IDs, component names, interface IDs, or parameters in parentheses (e.g., write "Compute Node Bay 14", "PSU 1 ถึง PSU 6", "พอร์ต GE1/0/23"). Parentheses are reserved solely for ISO clause references (e.g., A.5.37).
- **Form Formatting (`forms/`)**: Use clean plain text, bold, and markdown tables only. Avoid unnecessary backticks (code tags) and formatting clutter in compliance forms.
  - **Canonical Structure Baseline**: Strictly adhere to [forms/INT531_Lab1_ตัวอย่างเอกสาร_ISO27001.md](forms/INT531_Lab1_ตัวอย่างเอกสาร_ISO27001.md) as the authoritative template for table structures, section count, and concise single-line summaries. Never add extraneous tables, raw data dumps from `forms/source/`, or duplicate layout breakdowns beyond the baseline example.
  - **Table Schema Immutability**: Never modify, rename, add, or remove columns in compliance table headers (`INV-01`, `PWR-01`, `RACK-01`). Headers must strictly adhere to the standardized baseline.
  - **Column Semantic Integrity**: Never force data into a column that violates its designated semantic purpose (e.g., do not place IP addresses, OS versions, or wattages in `เหตุผลการจัดวาง`, `สเปกฮาร์ดแวร์`, or `ตำแหน่ง U`).
  - **Strict Secret Zero-Exposure**: Never disclose passwords, authentication passphrases, or credentials in compliance forms or audit records (`forms/`). Credentials belong strictly in secured technical source files (`forms/source/`).
- **Checklists & Questionnaires (`forms/คำถาม.md`)**: Use minimalist single-line prompts ending with a colon and trailing space (`[ข้อ]. [คำถามสั้นๆ]: `) with clean blank space for write-in answers. Never write verbose explanatory sentences or `<TBD>` clutter in questions. Keep compact verified/answered summary tables at the bottom.
- **Power & Cooling Calculations (`PWR-01`)**: Always compute heat dissipation row `ภาระความร้อนที่เพิ่มในห้อง` from total equipment power using formula $P_{\text{total}} \times 3.412142\text{ BTU/h}$. Never substitute this row with ambient room readings. Ambient sensor readings (e.g., 17.5 °C, 68 %RH) belong strictly in notes.
- **Placeholders**: Never invent arbitrary realistic-looking IP addresses (such as 10.13.104.10) as placeholders. Always use `<TBD>` or explicitly mark draft placeholders to prevent operational ambiguity.
- **Group Scope & Hardware Context**:
  - **Team Members**: นายภัคพล ธีรชัยศุภกิจ (Inventory Lead), นายยุทธภูมิ ฮาบพนม (Change Owner), นายศุภฤกษ์ กมลเนตร (Technical Reviewer).
  - **Assigned Compute Node**: Compute Node Bay 14 (Lenovo Flex System x240 M5, MT: 9532). Strictly scope all compute node configuration, management, and OS installation to Bay 14 only. Do not modify or claim other bays.
  - **Enterprise Chassis**: Lenovo Flex System Enterprise Chassis (Type: 8721, Model: HC1, S/N: 06EDLHG).
  - **Management Network (VLAN 100)**: CMM Static IP is 10.13.104.101 (Factory default: 192.168.70.100), Gateway 10.13.104.254.
  - **ToR Switch**: HP 5800-24G Switch (coreUTP_SW), CMM uplink connected to port GE1/0/23, Notebook management port GE1/0/24.
- **Large Manual Handling**: When inspecting large manuals in `forms/manuals/` (> 5,000 lines, e.g., Chapter 4), always map headings first using grep before targeted slicing, to avoid context bloat from massive event lookup tables.
- **Supplement, Never Truncate**: Enhance content using `transcript.md`. Never delete or omit original information from the slides.
- **Workspace Scope**: Keep all commands, searches, and file modifications strictly scoped within the repository workspace.

## Lecture Notes Workflow

- **Target File Pattern**: `week{NN}/INT531_W{NN}_{Topic}_สไลด์บรรยาย.md` (or `_Lecture_EN.md` for English slides).
- **Conventional Commits**:
  - Baseline: `feat(week{NN}): extract PDF slides to Thai markdown`
  - Supplement: `docs(week{NN}): supplement lecture notes with transcript insights`

1. **Extract Slides**: Convert all `.pdf` pages into a corresponding `.md` file, retaining all details, tables, and LaTeX math blocks ($...$).
2. **Slide Baseline Commit**: Commit the initial extracted slide notes to git using the `feat(week{NN})` commit pattern.
3. **Supplement from Transcript**: Synthesize instructor insights, practical examples, and lecture commentary from `transcript.md` into the `.md` note.
4. **Supplement Commit**: Commit the supplemented notes to git using the `docs(week{NN})` commit pattern.

## Repository Layout

- `week01` - `week13`: Lecture slides, transcribed markdown notes, and lecture transcripts.
- `exams/`: Exam slides, revision materials, and viva question guides.
- `forms/`: ISO/IEC 27001 compliance templates, lab operational records, and checklists.
  - `forms/day01/`: Day 1 submission (24 Sep 2569 — `CR-2569-001`, `AR-2569-001`, `MOP-01`, `ROLL-01`, `PWR-01`, `RACK-01`, `LOG-01`).
  - `forms/day02/`: Day 2 submission (2 Oct 2569 — `CR-2569-002`, `AR-2569-002`, `MOP-01`, `ROLL-01`, `LOG-01`).
  - `forms/day03/`: Day 3 submission (9 Oct 2569 — `CR-2569-003`, `AR-2569-003`, `MOP-01`, `ROLL-01`, `INV-01`, `LOG-01`).
  - `forms/day04/`: Day 4 submission (15 Oct 2569 — `CR-2569-004`, `AR-2569-004`, `MOP-01`, `ROLL-01`, `INV-01`, `LOG-01`).
  - `forms/PWR-01.md`: Centralized power, UPS, and cooling calculation form.
  - `forms/RACK-01.md`: Centralized rack elevation (Rack-01 B2_Front) and physical layout form.
  - `forms/INV-01.md`: Centralized hardware inventory form (Tables ก & ข).
  - `forms/ROLL-01.md`: Centralized rollback plan form (CR-2569-001 ถึง CR-2569-004).
  - `forms/LOG-01.md`: Centralized site access log form (A.7.4).
  - `forms/source/คำถาม.md`: Active hardware inventory checklist and compute node bay allocations.
  - `forms/logs/`: Switch console logs and ToR network configuration history.
  - `forms/manuals/`: Vendor service and installation guides.
    - `Chapter 2`: Physical installation, rails, rack alignment (`CR-2569-001`, `RACK-01`).
    - `Chapter 3 & 4`: CMM initial setup, IMM networking, ToR integration, and troubleshooting abort criteria (`CR-2569-003`, `MOP-01`).
    - `Chapter 5`: Parts catalog, CRU/FRU taxonomy, PSU, fans, and CMM part numbers (`INV-01`, `AR-01`, `forms/คำถาม.md`).
    - `Chapter 6`: Component removal, ESD, 1-minute cooling rule, and rollback procedures (`ROLL-01`).

## Agent Skills

### Issue Tracker

Local markdown files under `.scratch/`. See `docs/agents/issue-tracker.md`.

### Domain Docs

Single-context (`GLOSSARY.md` + `docs/adr/` at repo root). See `docs/agents/domain.md`.

### Agent Lifecycle Hooks

Lifecycle hooks are configured in `.agents/hooks.json` to enforce safety and compliance guards:
- **PreToolUse (`run_command`)**: Blocks `git commit` or `git add` if `scripts/lint-forms.sh` detects any ISO 27001 table schema corruption or policy violations.
- **Stop**: Prevents agent termination on turn completion if forms fail compliance lint checks.
- Script runner: `scripts/agent-hook-lint.py`.
