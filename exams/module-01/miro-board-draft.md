# ร่างเนื้อหาสำหรับจัดวางบนบอร์ด Miro 1 หน้า (Miro Board 1-Page Draft)

เอกสารนี้ถูกออกแบบตามกติกาข้อ 3.3 ของข้อสอบ INT531:
- ขนาด: บอร์ด Miro **1 หน้าเท่านั้น (Single View Canvas)**
- วัตถุประสงค์: เป็น Runbook ทางสายตาสำหรับเปิดค้างไว้ระหว่างตอบคำถามปากเปล่า
- ข้อห้าม: ห้ามแก้ไขบอร์ดระหว่างการสอบ (ผู้คุมสอบจะตรวจ Timestamp การแก้ไขล่าสุด) และห้ามใส่ประโยคยาวเหยียดที่ทำให้ดูเหมือนอ่านโพย
- แนะนำให้จัดวางเป็น 6 โซน (6 Zones) ล้อมรอบกล่องตัวเลขลัดตรงกลาง

---

```text
+---------------------------------------------------------------------------------------------------+
|                                 MIRO BOARD: INT531 VIVA MODULE 1                                  |
+---------------------------------+---------------------------------+-------------------------------+
| [ZONE 1: SLO & ERROR BUDGET]    | [ZONE 2: DIAGNOSIS & USE/RED]   | [ZONE 3: METRICS & TSDB]      |
| - SLI: Good / Valid * 100%      | - Symptom: RED (User view)      | - Types: Counter, Gauge,      |
| - SLO: Target (e.g. 99.9%)      | - Cause: USE (Hardware view)    |   Histogram, Summary          |
| - Error Budget: 100% - SLO      | - Golden Signals: Latency,      | - Cardinality: Mult of Labels |
| - Policy: Budget empty -> Freeze  |   Traffic, Errors, Saturation   | - Trap: UserID/IP in Label    |
|   feature, fix technical debt   | - The Knee: Saturation > 80%    | - TSDB: 1.5 Bytes / Sample    |
| - Burn Rate: Rate / Budget      | - Commands: top, vmstat,        | - PromQL: rate(),             |
|   1 = Normal, 14.4 = 2-day burn |   iostat, ss, dmesg, pidstat    |   histogram_quantile(0.99,..) |
+---------------------------------+---------------------------------+-------------------------------+
|                                    [CENTER: MENTAL MATH QUICK]                                    |
|   - 30 Days = 43,000 Mins | 7 Days = 10,000 Mins | 1 Day = 1,440 Mins                             |
|   - 99% = 7 hrs/mo | 99.5% = 3.5 hrs/mo | 99.9% = 43 mins/mo | 99.99% = 4.3 mins/mo              |
|   - Series: A_total = A1 * A2 (Unavail adds up: 0.1% + 0.1% = 0.2% -> 99.8%)                      |
|   - Headroom: (Peak90d + Growth) / (N-1) / 0.8                                                    |
+---------------------------------+---------------------------------+-------------------------------+
| [ZONE 4: OBSERVABILITY PILLARS] | [ZONE 5: ISO 27001 & CHANGES]   | [ZONE 6: CAPACITY & POWER]    |
| - Metrics: What & When (TSDB)   | - A.5.9: Asset Inventory        | - Queue: Little's Law L = λ*W |
| - Logs: Why (JSON, Loki LogQL)  | - A.5.37: Documented MOP        | - Knee Curve: >80% queue blow |
| - Traces: Where (Waterfall)     | - A.7.4: Physical Monitoring    | - Rack: Single Point Failure  |
| - W3C Context: traceparent      | - A.7.8/A.7.12: Cabling/Separ   | - PDU: 230V * 16A = 3.6kW     |
| - Exemplars: Trace ID in Metric | - A.7.10/14: Media Disk Erase   | - De-rating 80% = max 12.8A   |
| - Sampling: Head, Tail, Rate    | - A.8.32: Change & Rollback     | - Inrush: 3-5x on Cold Boot   |
| - Anti-pattern: High Card Label | - Roles: Owner, Lead, Safety    | - ToR: Oversubscription ratio |
+---------------------------------+---------------------------------+-------------------------------+
```

---

## รายละเอียดเนื้อหาในแต่ละกล่องบนบอร์ด Miro

### โซนที่ 1: SLI / SLO / Error Budget (บนซ้าย)
- **หัวใจสำคัญ**:
  - $\text{SLI} = \frac{\text{Good Events}}{\text{Valid Events}} \times 100\%$ (วัดจากฝั่งผู้ใช้ ไม่ใช่ฝั่ง Server)
  - $\text{SLO}$: ข้อตกลงภายในระหว่าง Dev กับ SRE (เช่น 99.9% ในรอบ 30 วัน)
  - $\text{SLA}$: สัญญาทางธุรกิจที่มีผลผูกพันทางกฎหมายและการเงิน (มักตั้งต่ำกว่า SLO เสมอ เพื่อสร้างกันชน)
  - $\text{Error Budget} = 100\% - \text{SLO}$
- **Error Budget Policy**:
  - เหลือง (Burn Rate สูง): เตือนทีม Dev ทบทวนแผน Release
  - แดง (Budget หมด): Freeze Feature ทันที ทุกคนหันมาแก้ Reliability Debt และทำ Postmortem
- **แผนภาพจำลอง**: กราฟแท่งแสดงงบประมาณ 100% ค่อยๆ ลดลงตามเหตุการณ์ขัดข้อง

---

### โซนที่ 2: วินิจฉัยปัญหาประสิทธิภาพ USE / RED (บนกลาง)
- **กรอบความคิด 2 ด้าน**:
  - ผู้ใช้รู้สึกเจ็บปวด -> ดู **RED Method** (Rate, Errors, Duration)
  - หาว่าฮาร์ดแวร์ตัวไหนกำลังจะพัง -> ดู **USE Method** (Utilization, Saturation, Errors)
- **เครื่องมือ Linux Triage (จำคำสั่งหลัก)**:
  - `uptime` / `top` -> ดู Load Average เทียบกับจำนวน CPU Core
  - `vmstat 1` -> ดูคิว CPU (`r`) และการสลับหน้าหน่วยความจำ (`si`/`so` - Swap)
  - `iostat -xz 1` -> ดู `%util` และค่าหน่วงเวลา `await` เทียบกับ `svctm` (หา Disk Bottleneck)
  - `ss -s` หรือ `ss -tin` -> ดูจำนวน Connection ค้างและ TCP Retransmit
  - `dmesg -T | tail` -> ดูข้อความเตือนของเคอร์เนล เช่น OOM Killer, RAID Controller Fallback
- **กฎเหล็ก**: "บรรเทาก่อน แล้วค่อยแก้ราก" (Mitigate first, Root cause later)

---

### โซนที่ 3: เมตริกและ TSDB Cardinality (บนขวา)
- **ประเภทเมตริกใน Prometheus**:
  - `Counter`: เพิ่มขึ้นอย่างเดียว (ใช้คู่กับ `rate()`)
  - `Gauge`: ค่าขึ้นๆ ลงๆ เช่น อุณหภูมิ, Memory Usage
  - `Histogram`: แจกแจงความถี่เป็น Bucket (ใช้คู่กับ `histogram_quantile(0.99, ...)`)
  - `Summary`: คำนวณ Quantile ที่ฝั่ง Application Client
- **กับดัก High Cardinality**:
  - $\text{Total Series} = \text{Labels}_1 \times \text{Labels}_2 \times \dots \times \text{Labels}_n$
  - ข้อห้าม: ห้ามใส่ `user_id`, `email`, `order_id`, `ip_address`, `timestamp` ลงใน Label ของเมตริก
  - การแก้ไข: ย้ายมิติข้อมูลที่มีค่าไม่จำกัดไปไว้ใน Log หรือ Distributed Trace
- **สูตรขนาดดิสก์**: $\text{Disk} = \text{Series} \times \frac{\text{Retention Seconds}}{\text{Scrape Seconds}} \times 1.5 \text{ Bytes}$

---

### กล่องกลาง: ตัวเลขและสูตรคำนวณในใจ (Center Box)
- ฐานเวลา 30 วัน $= 43,000$ นาที
- $99\% = 430$ นาที $\approx 7$ ชั่วโมง
- $99.5\% = 215$ นาที $\approx 3.5$ ชั่วโมง
- $99.9\% = 43$ นาที
- $99.99\% = 4.3$ นาที
- ต่ออนุกรม: Error รวมกัน เช่น $99.9\% + 99.9\% \rightarrow 0.1\% + 0.1\% = 0.2\% \rightarrow 99.8\%$
- Little's Law: $L = \lambda \times W$ (จำนวนในระบบ $=$ อัตราไหลเข้า $\times$ เวลาที่อยู่ในระบบ)
- Headroom 4 ขั้น: Peak 90 วัน $\rightarrow +15\%$ โต $\rightarrow \div (N-1) \rightarrow \div 0.8$

---

### โซนที่ 4: 3 เสาหลักของ Observability (ล่างซ้าย)
- **Metrics**: ตอบว่า "มีอะไรเกิดขึ้น เมื่อไหร่ และขอบเขตเท่าใด" (ราคาถูก, กราฟแนวโน้ม, ไม่รู้ต้นตอเดี่ยว)
- **Logs**: ตอบว่า "ทำไมถึงเกิดขึ้น" (บริบทละเอียด, JSON Format, ค้นหายากถ้าไม่มีโครงสร้าง)
- **Traces**: ตอบว่า "เกิดขึ้นที่จุดไหนในสายการเรียกข้อมูล" (แผนภาพ Waterfall, ลำดับ Parent-Child Span)
- **W3C Trace Context**: Header `traceparent: 00-{trace_id}-{span_id}-{flags}`
- **การเชื่อมโยง (Correlation)**:
  - เมตริกพุ่ง -> คลิกดู Exemplar ดึง `trace_id`
  - นำ `trace_id` ไปสืบค้นบน Distributed Tracing -> เจอ Span ที่ช้า
  - นำ `trace_id` ไปค้นใน Grafana Loki (`{app="api"} |= "trace_id"`) -> เจอบันทึก Log ข้อผิดพลาดของคำร้องนั้น

---

### โซนที่ 5: มาตรฐานความปลอดภัย ISO/IEC 27001 และการเปลี่ยนแปลง (ล่างกลาง)
- **ข้อควบคุม Annex A ที่สำคัญ**:
  - `A.5.9`: Inventory of assets (ทะเบียนครุภัณฑ์ INV-01, MED-01 ระบุ Serial, U, Owner)
  - `A.5.37`: Documented operating procedures (ขั้นตอนปฏิบัติงาน MOP และเวลาประเมิน)
  - `A.7.4`: Physical security monitoring (สมุดลงชื่อเข้า-ออก LOG-01, กำกับผู้รับเหมา)
  - `A.7.8 / A.7.12`: Equipment siting, cabling security (แยกสายไฟซ้าย-สัญญาณขวา, รัศมีดัดโค้ง)
  - `A.7.10 / A.7.14`: Storage media handling (ทำลายข้อมูลตาม NIST SP 800-88 ก่อนปลดระวาง)
  - `A.7.11`: Supporting utilities (ตรวจกำลังไฟฟ้า PDU, ระบบทำความเย็น)
  - `A.8.32`: Change management (แบบคำขอเปลี่ยนแปลง AR-01, แผนย้อนกลับ Rollback Plan)
- **บทบาทในทีม**: Change Owner (ตัดสินใจ), Inventory Lead (ตรวจนับ), Safety Officer (คุมความปลอดภัย สั่งหยุดงานได้), Scribe (จดบันทึกเวลาจริง)

---

### โซนที่ 6: การวางแผนความจุและระบบไฟฟ้า Data Center (ล่างขวา)
- **จุดหักเลี้ยวของคิว (The Knee Curve)**:
  - การใช้งาน $< 50\%$: เวลาตอบสนองแทบไม่เปลี่ยน
  - การใช้งาน $> 80\%$: คิวเริ่มสะสม เวลาตอบสนองพุ่งแบบกึ่งเอกซ์โพเนนเชียล
  - การใช้งาน $100\%$: คิวไม่สิ้นสุด ระบบล่มกะทันหัน
- **ตู้ Rack ในฐานะระบบกระจาย**:
  - Single Point of Failure: PSU คู่แต่เสียบ PDU แถวเดียวกัน (ความซ้ำซ้อนปลอม)
  - กำลังไฟฟ้า: PDU $16\text{A} \times 230\text{V} \approx 3.6\text{ kW}$ (ใช้ต่อเนื่องไม่เกิน 80% $= 12.8\text{A}$)
  - Inrush Current: กระแสสตาร์ตพร้อมกัน 3-5 เท่า แก้ไขด้วย Staggered Power-on delay
- **เครือข่ายสวิตช์ Top of Rack (ToR)**:
  - Oversubscription Ratio: แบนด์วิดท์ฝั่งเซิร์ฟเวอร์ต่อแบนด์วิดท์ Uplink (ปกติ 2.5:1, กรณี N-1 ล่มกลายเป็น 5:1)
