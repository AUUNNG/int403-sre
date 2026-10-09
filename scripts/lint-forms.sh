#!/usr/bin/env bash
set -euo pipefail

# Linter for ISO/IEC 27001 Compliance Forms and Checklists
# Target files: Operational forms and checklist markdown documents in forms/

FILES=(
    "forms/INT531_Lab1_แบบฟอร์มยื่นเอกสาร_ISO27001.md"
    "forms/คำถาม.md"
)

ERRORS=0

echo "Running compliance forms linter..."

for f in "${FILES[@]}"; do
    if [ ! -f "$f" ]; then
        echo "WARNING: File not found: $f"
        continue
    fi

    # 1. Zero Emoji check
    # Detects emoji symbols in Unicode ranges while permitting form ballot boxes (☐ U+2610, ☑ U+2611)
    if grep -rnP '[\x{1F300}-\x{1FAFF}\x{2600}-\x{260F}\x{2612}-\x{26FF}\x{2700}-\x{27BF}]' "$f" 2>/dev/null; then
        echo "ERROR: Emoji detected in $f. Zero emoji rule violated."
        ERRORS=$((ERRORS + 1))
    fi

    # 2. Redundant Thai-English parentheses check
    # Disallows Thai followed by English in parentheses, e.g. "ทดสอบ (Test)"
    # Permits ISO Annex A clause numbers like (A.8.32) and form codes like (INV-01)
    if grep -rnP '[ก-๙]+\s*\([A-Za-z][A-Za-z0-9\s-]+\)' "$f" | \
       grep -v -P '\(A\.[0-9]' | \
       grep -v -P '\((INV|RACK|PWR|MOP|AR|RA|CR|MED|SAN|TRF|DIS|CLS|SIGN|LOG|PH)-[0-9]{2}\)' 2>/dev/null; then
        echo "ERROR: Redundant Thai-English parentheses detected in $f. Use direct English technical terms."
        ERRORS=$((ERRORS + 1))
    fi

    # 3. Deprecated placeholder IP check
    if grep -rn '10.13.104.10\b' "$f" 2>/dev/null; then
        echo "ERROR: Deprecated placeholder IP 10.13.104.10 found in $f. Use 10.13.104.101 or <TBD>."
        ERRORS=$((ERRORS + 1))
    fi

    # 4. Mandatory heat load row check in ISO 27001 compliance form
    if [ "$f" = "forms/INT531_Lab1_แบบฟอร์มยื่นเอกสาร_ISO27001.md" ]; then
        if ! grep -q 'ภาระความร้อนที่เพิ่มในห้อง' "$f"; then
            echo "ERROR: Missing mandatory row 'ภาระความร้อนที่เพิ่มในห้อง' in $f (PWR-01 calculation)."
            ERRORS=$((ERRORS + 1))
        fi
    fi
done

if [ "$ERRORS" -gt 0 ]; then
    echo "Forms linting failed with $ERRORS error(s)."
    exit 1
else
    echo "All forms lint checks passed successfully."
fi
