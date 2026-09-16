# ผังและโครงสร้างบอร์ด Miro ฉบับสมบูรณ์ (Miro Whiteboard 3x3 Grid Layout)

บอร์ด Miro นี้ถูกจัดทำขึ้นเป็น Visual Runbook สำหรับการสอบปากเปล่า **INT531 SRE Viva Exam (Module 1, Weeks 1-5)**:
- ลิงก์กระดานบน Miro: [INT531 SRE - Formulas & Calculations (Module 1)](https://miro.com/app/board/uXjVHmnlVLg=/)
- รูปแบบผัง: **3 แถว x 3 คอลัมน์ (รวม 9 เฟรมหลัก)**
- ระยะห่าง (Compact Spacing): ระยะห่างระหว่างแถวและคอลัมน์ชิดกันเพียง **30 px - 60 px** ทำให้เห็นภาพรวมแบบองค์รวม (Single Overview Canvas) ซูมดูได้ทันทีขณะตอบคำถามสด

---

## ผังภาพรวมของกระดาน 9 เฟรม (Miro 3x3 Dashboard Map)

```text
=================================================================================================================================
                                    INT531 SRE: สรุปภาพรวมสมบูรณ์ (Formula, Diagnostic & Comparison 3x3 Grid)
=================================================================================================================================
[ แถวที่ 1: สูตรคำนวณและการออกแบบขนาดระบบ (Formulas & Sizing) ]
+------------------------------------+------------------------------------+------------------------------------+
| 1. Service Level & Reliability     | 2. Performance, Queuing & Telemetry| 3. Physical Infra, Power & Network |
| (ชุดสีฟ้า #f0f5fd / #305bab)       | (ชุดสีเหลือง #fffbed / #af7e04)    | (ชุดสีเขียว #eaf9ef / #067429)     |
+------------------------------------+------------------------------------+------------------------------------+
| [1.1 SLI, SLO & Error Budget]      | [2.1 Little's Law & 4-Step Sizing] | [3.1 PDU Power & 80% De-rating]    |
| [1.2 Composite Availability]       | [2.2 Timeout Budget & Retry]       | [3.2 Network Oversubscription]     |
| [1.3 Burn Rate & Alerting]         | [2.3 Cardinality & TSDB Space]     | [3.3 PUE & Trace Tail Sampling]    |
+------------------------------------+------------------------------------+------------------------------------+
                                      (ระยะห่างชิดกัน 30px)
[ แถวที่ 2: ขั้นตอนการวินิจฉัย กับดักข้อสอบ และศูนย์ข้อมูลจริง (Playbooks, Traps & Physical DC) ]
+------------------------------------+------------------------------------+------------------------------------+
| 4. Diagnostic & Telemetry Matrix   | 5. Classic Traps & Killer Answers  | 6. Physical DC & ISO/IEC 27001     |
| (ชุดสีม่วง #f6f0fd / #6a23c6)      | (ชุดสีส้มอิฐ #fdf2ed / #b83a04)    | (ชุดสีเขียวน้ำทะเล #edf8f9/#006d77)|
+------------------------------------+------------------------------------+------------------------------------+
| [4.1 Linux 60-Second Checklist]    | [5.1 Reliability Traps]            | [6.1 Rack Elevation & Cooling]     |
| [4.2 USE vs RED vs 4 Signals]      | [5.2 Observability Traps]          | [6.2 Spine-Leaf vs 3-Tier Network] |
| [4.3 OpenTelemetry Pipeline]       | [5.3 Architecture Traps]           | [6.3 ISO 27001 Forms & Roles]      |
+------------------------------------+------------------------------------+------------------------------------+
                                      (ระยะห่างชิดกัน 30px)
[ แถวที่ 3: ตารางเปรียบเทียบเชิงลึกและเกณฑ์การตัดสินใจ (Comparison Matrices & Trade-offs) ]
+------------------------------------+------------------------------------+------------------------------------+
| 7. Discipline & Reliability        | 8. Observability & Telemetry       | 9. Physical DC & Hardware Arch     |
| (ชุดสีกุหลาบ #fff0f0 / #bd0a0a)    | (ชุดสีอำพัน #fff5ed / #9b4a08)     | (ชุดสีมิ้นต์ #eaf9ef / #067429)    |
+------------------------------------+------------------------------------+------------------------------------+
| [7.1 เปรียบเทียบ 4 สายงานระบบ]     | [8.1 เปรียบเทียบ 3 เสาหลัก]        | [9.1 Spine-Leaf vs 3-Tier Network] |
| - Traditional Ops vs DevOps vs SRE | - Metrics vs Logs vs Traces        | - East-West vs North-South         |
|   vs Platform Engineering          | - จุดเด่น จุดด้อย และต้นทุน        | - ECMP vs STP, Exactly 3 Hops      |
| [7.2 เมทริกซ์ SLI vs SLO vs SLA]   | [8.2 ชนิดเมตริกใน Prometheus]      | [9.2 สื่อเชื่อมต่อสวิตช์ ToR]      |
| - ผู้รับผิดชอบ และผลเมื่อพัง       | - Counter, Gauge, Histogram, Sum   | - DAC vs AOC vs Discrete Fiber     |
| - Safety Buffer ป้องกันถูกปรับเงิน  | - ทำไม Summary ห้ามรวมข้ามโหนด     | - รหัสสี OM3, OM4, OM5, OS2        |
| [7.3 ตารางต้นทุนเลข 9 & Downtime]  | [8.3 สถาปัตยกรรม Log & Sampling]   | [9.3 เอกสาร ISO & บทบาทแล็บ]       |
| - 99% ถึง 99.999% ต่อ 30 วัน/ปี    | - Grafana Loki vs Elasticsearch    | - AR-01, LOG-01, INV-01, MED-01    |
| - สถาปัตยกรรมที่จำเป็นต้องใช้      | - Head Sampling vs Tail Sampling   | - Owner, Lead, Safety, Scribe      |
+------------------------------------+------------------------------------+------------------------------------+
```

---

## สรุปสาระสำคัญประจำแต่ละเฟรม (Quick Reference)

### แถวที่ 1: สูตรคำนวณและการออกแบบความจุ (Mathematical Foundations)
1. **Frame 1 (Service Level & Reliability):** $\text{SLI} = \frac{\text{Good}}{\text{Valid}} \times 100\%$, $\text{Error Budget} = 100\% - \text{SLO}$, อนุกรมคูณความเสถียร (บวก Error รวม), ขนานคูณความไม่เสถียร ($U_1 \times U_2$), Burn Rate = $\frac{1 - \text{SLI}}{1 - \text{SLO}}$
2. **Frame 2 (Performance & Queuing):** กฎ Little's Law ($L = \lambda \times W$), Headroom 4 สเต็ป ($\text{Peak}_{90\text{d}} \times 1.15 \div (N-1) \div 0.8$), Timeout จากบนลงล่าง, Retry Budget $\le 10\%$, TSDB Disk Size = $\text{Series} \times \text{Samples} \times 1.5\text{ Bytes}$
3. **Frame 3 (Physical Infra & Network):** $P = V \times I$ ($230\text{V} \times 16\text{A} = 3.68\text{kW}$), 80% De-rating Continuous = $12.8\text{A}$, Inrush Current $3-5\times$ (Staggered boot delay 10s), Network Oversubscription ปกติ 3:1 (N-1 พุ่งเป็น 6:1)

### แถวที่ 2: ขั้นตอนการแก้ปัญหา กับดักข้อสอบ และความปลอดภัย (Operational Playbooks)
4. **Frame 4 (Diagnostic Playbook):** 6 คำสั่ง Linux ใน 60 วินาที (`uptime` $\rightarrow$ `dmesg` $\rightarrow$ `vmstat` $\rightarrow$ `iostat` $\rightarrow$ `ss` $\rightarrow$ `top`), เคสคลาสสิก BBU แบตเตอรี่ RAID เสื่อมตัดเข้า Write-Through, กรอบ USE (Hardware Cause) vs RED (Software Symptom) vs 4 Golden Signals, ไปป์ไลน์ OpenTelemetry และการเชื่อมโยงด้วย `trace_id` และ Exemplars
5. **Frame 5 (Classic Traps & Killer Answers):** ทำไมไม่เอา 100% SLO (Diminishing returns & Opp cost), Error Budget หมดต้อง Feature Freeze, Reboot Culture ทำลายหลักฐาน, The Flaw of Averages (ใช้ p99), High Cardinality ใน Prometheus, False Redundancy เสียบ PDU รางเดียวกัน, พายุ Retry Storm
6. **Frame 6 (Physical DC Setup):** กฎจุดศูนย์ถ่วง Bottom-Up (ของหนักอยู่ล่างสุด 1U-8U, สวิตช์ ToR อยู่บน 38U-42U), แยกสายไฟซ้าย-สัญญาณขวา (กัน EMI), กักเก็บลม Cold/Hot Aisle, ความสำคัญของ Blanking Panels ป้องกันความร้อนวนกลับ, การควบคุมตาม ISO/IEC 27001 Annex A

### แถวที่ 3: ตารางเปรียบเทียบเชิงลึกและเกณฑ์การตัดสินใจ (Comparative Matrices)
7. **Frame 7 (Discipline & Reliability):** เปรียบเทียบ Ops vs DevOps vs SRE vs Platform Engineering, เมทริกซ์ SLI vs SLO vs SLA (นิยาม/ผู้รับผิดชอบ/ผลเมื่อตกเกณฑ์), ตารางต้นทุนเลข 9 และ Allowable Downtime (99% พักได้ 7 ชม./เดือน จนถึง 99.999% พักได้ 26 วินาที/เดือน)
8. **Frame 8 (Observability & Telemetry):** เปรียบเทียบ 3 เสาหลัก (Metrics vs Logs vs Traces), 4 ชนิดเมตริกใน Prometheus (Counter, Gauge, Histogram, Summary - จุดตายคือ Summary รวมผลข้ามโหนดไม่ได้), Grafana Loki vs Elasticsearch (Index Metadata vs Full-text), กลยุทธ์สุ่ม Trace (Head vs Tail Sampling)
9. **Frame 9 (Physical DC & Architecture):** Spine-Leaf vs Traditional 3-Tier (East-West vs North-South, ECMP vs STP, Exactly 3 Hops), สื่อเชื่อมต่อ ToR (DAC vs AOC vs Fiber Transceiver, รหัสสี OM3 ฟ้า, OM4 ม่วง, OS2 เหลือง), แบบฟอร์ม ISO ในแล็บ (AR-01, LOG-01, INV-01, MED-01) และ 4 บทบาทในทีม
