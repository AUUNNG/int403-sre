# ผังและโครงสร้างบอร์ด Miro แบบสมบูรณ์ (Miro Whiteboard 2x3 Grid Layout)

บอร์ด Miro นี้ถูกสร้างขึ้นเพื่อเป็น Visual Runbook สำหรับการสอบปากเปล่า **INT531 SRE Viva Exam (Module 1, Weeks 1-5)**:
- ลิงก์กระดานบน Miro: [INT531 SRE - Formulas & Calculations (Module 1)](https://miro.com/app/board/uXjVHmnlVLg=/)
- รูปแบบผัง: **2 แถว x 3 คอลัมน์ (รวม 6 เฟรมหลัก)**
- การจัดวาง: ลดระยะห่าง (Compact Spacing) เฟรมแถวบนและแถวล่างอยู่ชิดกัน (Gap 30px) กวาดสายตามองเห็นได้ครบทุกโซนโดยไม่ต้องซูมเข้าออกบ่อย

---

## ผังภาพรวมของกระดาน (Miro Canvas Map)

```text
=================================================================================================================================
                                    INT531 SRE: สูตรคำนวณและวิธีคิดลัด (Formula & Sizing Whiteboard Weeks 1-5)
=================================================================================================================================
[ แถวที่ 1: สูตรคำนวณและการออกแบบขนาดระบบ (Formulas & Sizing) ]
+------------------------------------+------------------------------------+------------------------------------+
| 1. Service Level & Reliability     | 2. Performance, Queuing & Telemetry| 3. Physical Infra, Power & Network |
| (ชุดสีฟ้า #f0f5fd / #305bab)       | (ชุดสีเหลือง #fffbed / #af7e04)    | (ชุดสีเขียว #eaf9ef / #067429)     |
+------------------------------------+------------------------------------+------------------------------------+
| [1.1 SLI, SLO & Error Budget]      | [2.1 Little's Law & 4-Step Sizing] | [3.1 PDU Power & 80% De-rating]    |
| - SLI = Good / Valid * 100%        | - L = Lambda * W                   | - P = V * I (230V * 16A = 3.68kW)  |
| - Error Budget = 100% - SLO        | - Peak90d + Growth / (N-1) / 0.8   | - กฎลดพิกัด 80% Max = 12.8A        |
| - 30 วัน = 43,000 นาที             | - The Knee Curve (>80% คิวระเบิด)  | - Inrush Current 3-5x & Staggered  |
| - ตารางลัด 99% ถึง 99.99%          | - สเต็ปคำนวณ 1,200 RPS สู่โหนดจริง | - False Redundancy Dual PSU        |
+------------------------------------+------------------------------------+------------------------------------+
| [1.2 Composite Availability]       | [2.2 Timeout Budget & Retry]       | [3.2 Network Oversubscription]     |
| - Series: A_total = A1 * A2        | - T_client > Web > API > DB        | - Downlink BW / Uplink BW          |
| - Parallel: U_total = U1 * U2      | - Retry Budget <= 10%              | - สัดส่วน ToR ปกติ 3:1             |
| - กฎบวก Error ในใจ (0.1+0.1=0.2%)  | - Exponential Backoff + Jitter     | - สภาวะ N-1 พุ่งเป็น 6:1 (Drop)    |
+------------------------------------+------------------------------------+------------------------------------+
| [1.3 Burn Rate & Alerting]         | [2.3 Cardinality & TSDB Space]     | [3.3 PUE & Trace Tail Sampling]    |
| - Burn Rate = Error / (1-SLO)      | - Cartesian Product of Labels      | - PUE = Total DC / IT Energy       |
| - Time to Exhaustion (30 วัน / BR) | - กับดัก user_id ทำ RAM ระเบิด     | - Blanking Panels ปรับปรุง PUE     |
| - สเกลเตือน 1x, 5x, 14.4x (Page)   | - TSDB Disk = Series * N * 1.5 B   | - Tail Sampling เก็บ Error 100%    |
+------------------------------------+------------------------------------+------------------------------------+

[ แถวที่ 2: ขั้นตอนการวินิจฉัย กับดักข้อสอบ และศูนย์ข้อมูลจริง (Playbooks, Traps & Physical DC) ]
+------------------------------------+------------------------------------+------------------------------------+
| 4. Diagnostic & Telemetry Matrix   | 5. Classic Traps & Killer Answers  | 6. Physical DC & ISO/IEC 27001     |
| (ชุดสีม่วง #f6f0fd / #6a23c6)      | (ชุดสีส้มอิฐ #fdf2ed / #b83a04)    | (ชุดสีเขียวน้ำทะเล #edf8f9/#006d77)|
+------------------------------------+------------------------------------+------------------------------------+
| [4.1 Linux 60-Second Checklist]    | [5.1 Reliability Traps]            | [6.1 Rack Elevation & Cooling]     |
| - 1. uptime (Load vs Cores)        | - ทำไมไม่ตั้ง 100%? (Diminishing)  | - Bottom-Up หนักสุดอยู่ล่าง (UPS)  |
| - 2. dmesg -T (Kernel, OOM, Drop)  | - Error Budget หมด -> Freeze Dev   | - แยกสายไฟซ้าย สายสัญญาณขวา (EMI)  |
| - 3. vmstat 1 (r, si/so - Swap)    | - Reboot Culture (Anti-pattern)    | - Cold/Hot Aisle & Blanking Panel  |
| - 4. iostat -xz 1 (%util, await)   | - เคสจริง: BBU RAID เสื่อม         | - ป้องกัน Thermal Short-circuit    |
+------------------------------------+------------------------------------+------------------------------------+
| [4.2 USE vs RED vs 4 Signals]      | [5.2 Observability Traps]          | [6.2 Spine-Leaf vs 3-Tier Network] |
| - USE: Hardware & OS Resources     | - The Flaw of Averages (ใช้ p99)   | - Spine-Leaf รองรับ East-West      |
| - RED: Software & API Endpoints    | - High Cardinality Bomb (Prom)     | - ECMP วิ่งได้ทุกเส้นทางพร้อมกัน   |
| - 4 Signals: User-Facing Services  | - Loki Index (Metadata vs Grep)    | - Exactly 3 Hops ทุกโหนดใน DC      |
+------------------------------------+------------------------------------+------------------------------------+
| [4.3 OpenTelemetry Pipeline]       | [5.3 Architecture Traps]           | [6.3 ISO 27001 Forms & Roles]      |
| - App OTel SDK -> OTel Collector   | - Retry Storm (ทราฟฟิกทวีคูณ)      | - AR-01: Asset Registration (A5.9) |
| - Processors: Batch, Tail Sampling | - False Redundancy (เสียบ PDU เดียว)| - LOG-01: Access & Incident (A7.1) |
| - Backends: Prom, Loki, Tempo      | - Inrush Trip (ไฟกระชาก Cold Boot) | - INV-01: Inventory, MED-01: Erase |
| - Correlation: trace_id & Exemplar | - Staggered Delay ใน BIOS หน่วง 10s| - 4 บทบาท: Owner, Lead, Safety, Scribe |
+------------------------------------+------------------------------------+------------------------------------+
```

---

## สรุปเนื้อหาสำคัญสำหรับทบทวนก่อนเข้าห้องสอบ

### 1. กฎการคำนวณและสัดส่วนที่ห้ามลืม
- **30 วัน = 43,000 นาที** (ใช้คำนวณ Downtime ได้ทันทีไม่ต้องกดเครื่องคิดเลข)
- **เพดาน 80% (The Knee Curve):** คุมการใช้งานไม่เกิน 80% เสมอ เพราะถ้าเกิน กราฟแถวคอยจะพุ่งสูงแบบ Exponential
- **$N-1$ Redundancy:** การคำนวณโหนดต้องหารด้วย $(N-1)$ เพื่อรองรับกรณีมีเครื่องพัง 1 เครื่องเสมอ
- **PDU 16A De-rating 80%:** กำลังพิกัด 3,680W ใช้งานต่อเนื่องได้สูงสุด **$12.8\text{A}$** หรือประมาณ 2,940W

### 2. ลำดับการตอบคำถามแนว Troubleshooting
- **60-Second Sequence:** `uptime` $\rightarrow$ `dmesg -T | tail` $\rightarrow$ `vmstat 1` $\rightarrow$ `iostat -xz 1` $\rightarrow$ `ss -tulpn` $\rightarrow$ `pidstat 1 / top`
- **เคสคลาสสิกของคณะ:** ระบบลงทะเบียนช้า Web/API CPU ต่ำ แต่ `iostat` พบ `%util = 100%` และ `await` สูง เกิดจาก **แบตเตอรี่ RAID Controller (BBU) เสื่อมสภาพ** ทำให้ตัดเข้าสู่โหมด **Write-Through** ฉุกเฉิน

### 3. คีย์เวิร์ดสังหารสำหรับคำถามดักคอ (Killer Answers)
- **ทำไมไม่เอา 100% Availability?** $\rightarrow$ ผู้ใช้ปลายทางต่อผ่านเน็ตมือถือ 4G/WiFi ที่เสถียรเพียง 99%, ต้นทุนก้าวกระโดด (Diminishing returns), เสียโอกาสทางนวัตกรรม (Opportunity cost)
- **ทำไมห้ามใช้ค่าเฉลี่ย (Average)?** $\rightarrow$ The Flaw of Averages บดบังความทุกข์ทรมานของกลุ่มช้าสุด ต้องดู **Percentile (p95, p99)**
- **ทำไมห้ามใส่ User ID ใน Prometheus?** $\rightarrow$ High Cardinality Bomb เส้น Time Series คูณกันแบบ Cartesian Product ทำให้ RAM ระเบิด OOM
- **ทำไมยิ่ง Retry ระบบยิ่งล่ม?** $\rightarrow$ Retry Storm ซ้ำเติมโหนดที่กำลังช้า ต้องแก้ด้วย **Exponential Backoff + Jitter** และเพดาน **Retry Budget $\le 10\%$**
- **ทำไมต้องต่อ Dual PSU ข้าม PDU?** $\rightarrow$ ป้องกัน False Redundancy หากเสียบ PDU รางเดียวกัน PDU ทริปเครื่องดับทันที
