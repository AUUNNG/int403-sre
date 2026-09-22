# ข้อกำหนดการทำงานของ AI Agent (AGENTS.md)

## กฎหลัก (Core Rules)
- **Zero Emoji**: ห้ามมี Emoji ในเนื้อหาเอกสาร, ข้อความ Git commit และข้อความตอบกลับเด็ดขาด
- **ห้ามใช้สคริปต์อ่าน PDF**: ใช้เครื่องมือ `view_file` อ่าน PDF โดยตรงเท่านั้น ห้ามใช้ Python, uv หรือสคริปต์ภายนอก
- **ภาษา**: ใช้ภาษาไทยเป็นหลักที่อ่านเข้าใจง่ายสำหรับการทบทวน และคงคำศัพท์เทคนิคภาษาอังกฤษไว้ในวงเล็บเสมอ เช่น "งบประมาณความผิดพลาด (Error Budget)"
- **เสริมเนื้อหา ห้ามตัดทอน**: นำข้อมูลจาก `transcript.md` มาเสริมต่อยอด ห้ามลบหรือลดทอนเนื้อหาเดิมจากสไลด์

## ขั้นตอนการทำงาน 4 ขั้นตอน (Standard Workflow)
1. **อ่าน PDF เป็น Markdown**: สกัดเนื้อหาจาก `.pdf` ทุกหน้าเป็น `.md` (ตั้งชื่อไฟล์ตรงกัน) เก็บรายละเอียด ตาราง และสูตรคณิตศาสตร์ ($...$) ให้ครบถ้วน
2. **Commit รอบ PDF**: บันทึก git commit สำหรับเนื้อหาตั้งต้นจากสไลด์
3. **อ่าน transcript.md เสริมเนื้อหา**: สังเคราะห์คำอธิบาย ตัวอย่างจริง และข้อคิดเห็นจากผู้สอน นำมาเสริมลงในไฟล์ `.md` ให้ได้เนื้อหาครอบคลุมที่สุด
4. **Commit รอบ Supplement**: บันทึก git commit สำหรับเนื้อหาที่เสริมจาก transcript

## คำสั่ง Git บน Windows (Retry Loop)
ใช้คำสั่งนี้เสมอเพื่อป้องกันปัญหา `index.lock` บน Windows:
```powershell
$maxRetry = 30; $done = $false; for ($i = 0; $i -lt $maxRetry; $i++) { git add <files>; git commit -m "<message>"; if ($LASTEXITCODE -eq 0) { $done = $true; break }; Start-Sleep -Milliseconds (Get-Random -Minimum 1000 -Maximum 3000) }
```
