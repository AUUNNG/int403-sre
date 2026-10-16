#!/usr/bin/env bash
set -euo pipefail

# Linter for ISO/IEC 27001 Compliance Forms and Checklists
# Target files: Operational forms and checklist markdown documents in forms/

FILES=(
    "forms/day01/1_Bob_เอกสาร_ISO27001_24_Sep_2026.md"
    "forms/day02/2_Bob_เอกสาร_ISO27001_2_Oct_2026.md"
    "forms/day03/3_Bob_เอกสาร_ISO27001_9_Oct_2026.md"
    "forms/day04/4_Bob_เอกสาร_ISO27001_15_Oct_2026.md"
    "forms/PWR-01.md"
    "forms/RACK-01.md"
    "forms/INV-01.md"
    "forms/ROLL-01.md"
    "forms/LOG-01.md"
    "forms/source/คำถาม.md"
)

ERRORS=0

echo "Running compliance forms linter..."

# 1. Global Zero Emoji check across all markdown files in the repository
# Detects emoji symbols in Unicode ranges while permitting form ballot boxes (☐ U+2610, ☑ U+2611)
while IFS= read -r md_file; do
    if [ -f "$md_file" ]; then
        if grep -rnP '[\x{1F300}-\x{1FAFF}\x{2600}-\x{260F}\x{2612}-\x{26FF}\x{2700}-\x{27BF}]' "$md_file" 2>/dev/null; then
            echo "ERROR: Emoji detected in $md_file. Zero emoji rule violated."
            ERRORS=$((ERRORS + 1))
        fi
    fi
done < <(find . -name "*.md" -not -path "*/.git/*" -not -path "*/.scratch/*")

for f in "${FILES[@]}"; do
    if [ ! -f "$f" ]; then
        echo "WARNING: File not found: $f"
        continue
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
    if [ "$f" = "forms/PWR-01.md" ]; then
        if ! grep -q 'ภาระความร้อนที่เพิ่มในห้อง' "$f"; then
            echo "ERROR: Missing mandatory row 'ภาระความร้อนที่เพิ่มในห้อง' in $f (PWR-01 calculation)."
            ERRORS=$((ERRORS + 1))
        fi
    fi

    # 4.1 Strict Secret Zero-Exposure check
    if grep -rnP '(Password|Passphrase)\s*[:=]\s*[^\s]+' "$f" 2>/dev/null; then
        echo "ERROR: Credential or password detected in $f. Strict Secret Zero-Exposure violated."
        ERRORS=$((ERRORS + 1))
    fi


    # 5. Table Header Schema assertions for compliance forms
    if [ "$f" = "forms/INV-01.md" ]; then
        if ! grep -q '^| # | ตำแหน่ง U | ประเภทอุปกรณ์ | ยี่ห้อ / รุ่น | Serial Number | หมายเลขครุภัณฑ์ |$' "$f"; then
            echo "ERROR: Table ก header corrupted in $f. Header must strictly match standard baseline."
            ERRORS=$((ERRORS + 1))
        fi
        if ! grep -q '^| # | เจ้าของ / ผู้ดูแลระบบ | บริการที่รันอยู่ | ระดับวิกฤต | สเปกฮาร์ดแวร์และดิสก์ภายใน | ปลายทาง | สภาพการทำงาน |$' "$f"; then
            echo "ERROR: Table ข header corrupted in $f. Header must strictly match standard baseline."
            ERRORS=$((ERRORS + 1))
        fi
    elif [ "$f" = "forms/PWR-01.md" ]; then
        if ! grep -q '^| # | อุปกรณ์ | จำนวน PSU | กำลังไฟใช้งานจริง (W) | ต่อ PDU A (W) | ต่อ PDU B (W) | หมายเหตุ |$' "$f"; then
            echo "ERROR: Table 1 header corrupted in $f. Header must strictly match standard baseline."
            ERRORS=$((ERRORS + 1))
        fi
        if ! grep -q '^| รายการ | ค่าที่คำนวณได้ | เกณฑ์ | ผล |$' "$f"; then
            echo "ERROR: Table 2 header corrupted in $f. Header must strictly match standard baseline."
            ERRORS=$((ERRORS + 1))
        fi
    elif [ "$f" = "forms/RACK-01.md" ]; then
        if ! grep -q '^| ตำแหน่ง U | อุปกรณ์ | ขนาด U | น้ำหนัก กก. | PDU | เหตุผลการจัดวาง |$' "$f"; then
            echo "ERROR: Table 1 header corrupted in $f. Header must strictly match standard baseline."
            ERRORS=$((ERRORS + 1))
        fi
        if ! grep -q '^| ช่องติดตั้งฝั่งซ้าย | ผู้ดูแล | หมายเลขประจำตัว | ช่องติดตั้งฝั่งขวา | ผู้ดูแล | หมายเลขประจำตัว |$' "$f"; then
            echo "ERROR: Blade chassis bay table header corrupted in $f."
            ERRORS=$((ERRORS + 1))
        fi
    elif [ "$f" = "forms/LOG-01.md" ]; then
        if ! grep -q '^| วันที่ | เวลาเข้า | เวลาออก | ชื่อ–สกุล | รหัส/สังกัด | ประเภท | วัตถุประสงค์ | ผู้ควบคุม | ลายมือชื่อ |$' "$f"; then
            echo "ERROR: Table header corrupted in $f. Header must strictly match standard baseline."
            ERRORS=$((ERRORS + 1))
        fi
    elif [ "$f" = "forms/ROLL-01.md" ]; then
        if ! grep -q '^| ขั้น | ขั้นตอนย้อนกลับ | เวลาโดยประมาณ | ผู้รับผิดชอบ | สิ่งที่ต้องเตรียมล่วงหน้า | จุดตรวจสอบ |$' "$f"; then
            echo "ERROR: Table header corrupted in $f. Header must strictly match standard baseline."
            ERRORS=$((ERRORS + 1))
        fi
    fi

    # 6. Column Semantic Purpose Integrity checks
    if [ "$f" = "forms/RACK-01.md" ]; then
        # Ensure 'เหตุผลการจัดวาง' in Table 1 does not contain network IP addresses
        if grep -n '^|.*|.*|.*|.*|.*|.*10\.13\.104\.' "$f" 2>/dev/null; then
            echo "ERROR: IP address detected in 'เหตุผลการจัดวาง' column of $f. Physical reasons only."
            ERRORS=$((ERRORS + 1))
        fi
    fi
    if [ "$f" = "forms/INV-01.md" ]; then
        # Ensure Table ก data rows do not contain IP addresses
        if sed -n '/### ตาราง ก/,/### ตาราง ข/p' "$f" | grep -n '^| [0-9]\+ |.*10\.13\.104\.' 2>/dev/null; then
            echo "ERROR: IP address detected in Table ก of $f. Network IPs belong in notes or network plan."
            ERRORS=$((ERRORS + 1))
        fi
    fi

    # 7. Table Count bounds to prevent extraneous tables and bloat
    if [ "$f" = "forms/INV-01.md" ]; then
        TABLE_COUNT=$(grep -c '^| :----' "$f" || true)
        if [ "$TABLE_COUNT" -gt 2 ]; then
            echo "ERROR: Extraneous tables detected in $f ($TABLE_COUNT tables found, max 2 allowed: ตาราง ก และ ตาราง ข)."
            ERRORS=$((ERRORS + 1))
        fi
    elif [ "$f" = "forms/PWR-01.md" ]; then
        TABLE_COUNT=$(grep -c '^| :----' "$f" || true)
        if [ "$TABLE_COUNT" -gt 3 ]; then
            echo "ERROR: Extraneous tables detected in $f ($TABLE_COUNT tables found, max 3 allowed)."
            ERRORS=$((ERRORS + 1))
        fi
    elif [ "$f" = "forms/RACK-01.md" ]; then
        TABLE_COUNT=$(grep -c '^| :----' "$f" || true)
        if [ "$TABLE_COUNT" -gt 2 ]; then
            echo "ERROR: Extraneous tables detected in $f ($TABLE_COUNT tables found, max 2 allowed)."
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
