# Agent Guidelines

## Core Rules

- **Zero Emoji**: Never include emojis in document content, git commit messages, or agent responses.
- **No PDF Scripts**: Never use Python, uv, or external scripts to process PDFs. Inspect PDFs directly via `Read`.
- **Language**:
  - **Study Notes (`week01` - `week09`)**: Use Thai as the primary language, preserving English technical terms in parentheses, e.g., "งบประมาณความผิดพลาด (Error Budget)".
  - **Operational Forms & MOPs (`forms/`)**: Use English technical terms directly without redundant Thai translations in parentheses (e.g., CMM, Compute Node, ToR Switch) for operational clarity.
- **Form Formatting (`forms/`)**: Use clean plain text, bold, and markdown tables only. Avoid unnecessary backticks (code tags) and formatting clutter in compliance forms.
- **Large Manual Handling**: When inspecting large manuals in `forms/manuals/` (> 5,000 lines, e.g., Chapter 4), always map headings first using grep before targeted slicing, to avoid context bloat from massive event lookup tables.
- **Supplement, Never Truncate**: Enhance content using `transcript.md`. Never delete or omit original information from the slides.
- **Workspace Scope**: Keep all commands, searches, and file modifications strictly scoped within the repository workspace.

## Lecture Notes Workflow

1. **Extract Slides**: Convert all `.pdf` pages into a corresponding `.md` file, retaining all details, tables, and LaTeX math blocks ($...$).
2. **Slide Baseline Commit**: Commit the initial extracted slide notes to git.
3. **Supplement from Transcript**: Synthesize instructor insights, practical examples, and lecture commentary from `transcript.md` into the `.md` note.
4. **Supplement Commit**: Commit the supplemented notes to git.

## Repository Layout

- `week01` - `week09`: Lecture slides, transcribed markdown notes, and lecture transcripts.
- `exams/`: Exam slides, revision materials, and viva question guides.
- `forms/`: ISO/IEC 27001 compliance templates, lab operational records, and checklists.
  - `forms/คำถาม.md`: Active hardware inventory checklist and compute node bay allocations.
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
