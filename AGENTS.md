# Agent Guidelines

## Core Rules

- **Zero Emoji**: Never include emojis in document content, git commit messages, or agent responses.
- **No PDF Scripts**: Never use Python, uv, or external scripts to process PDFs. Inspect PDFs directly via `Read`.
- **Language**: Use Thai as the primary language for study notes, always preserving English technical terms in parentheses, e.g., "งบประมาณความผิดพลาด (Error Budget)".
- **Supplement, Never Truncate**: Enhance content using `transcript.md`. Never delete or omit original information from the slides.

## Lecture Notes Workflow

1. **Extract Slides**: Convert all `.pdf` pages into a corresponding `.md` file, retaining all details, tables, and LaTeX math blocks ($...$).
2. **Slide Baseline Commit**: Commit the initial extracted slide notes to git.
3. **Supplement from Transcript**: Synthesize instructor insights, practical examples, and lecture commentary from `transcript.md` into the `.md` note.
4. **Supplement Commit**: Commit the supplemented notes to git.

## Repository Layout

- `week01` - `week09`: Lecture slides, transcribed markdown notes, and lecture transcripts.
- `exams/`: Exam slides, revision materials, and viva question guides.
- `forms/`: ISO/IEC 27001 compliance templates, lab operational records, and checklists.

## Agent Skills

### Issue Tracker

Local markdown files under `.scratch/`. See `docs/agents/issue-tracker.md`.

### Domain Docs

Single-context (`GLOSSARY.md` + `docs/adr/` at repo root). See `docs/agents/domain.md`.
