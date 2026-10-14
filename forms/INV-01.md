# **INV-01 — ทะเบียนครุภัณฑ์**

**ข้อควบคุมที่เกี่ยวข้อง: A.5.9**

**รหัสเอกสาร** INV-01 · **ตู้ต้นทาง/ปลายทาง** Rack-01 (B2_Front) ห้อง N16-0810 Taxila Room อาคาร SIT  
**ผู้สำรวจ** นายภัคพล ธีรชัยศุภกิจ · **วันที่สำรวจ** 9 ตุลาคม 2569 · **หน้า** 1/1  

---

### ตาราง ก — ข้อมูลระบุตัวตนทางกายภาพ

| # | ตำแหน่ง U | ประเภทอุปกรณ์ | ยี่ห้อ / รุ่น | Serial Number | หมายเลขครุภัณฑ์ |
| :---- | :---- | :---- | :---- | :---- | :---- |
| 1 | 42 | Ethernet Switch | Core Network Switch | <TBD> | <TBD> |
| 2 | 39 | Ethernet Switch | Core Network Switch | <TBD> | <TBD> |
| 3 | 38 | Ethernet Switch | HP 5800 Network Switch | CN2ABFN02G | <TBD> |
| 4 | 37 | Ethernet Switch | HP 5800 Network Switch | CN2ABFN003 | <TBD> |
| 5 | 29 | Rackmount Server | Dell PowerEdge R220 | 48PNF42 | <TBD> |
| 6 | 28 | Rackmount Server | Dell PowerEdge R210 | FJ7W92S | <TBD> |
| 7 | 27 | Rackmount Server | Dell PowerEdge R220 | 22C5T92 | <TBD> |
| 8 | 25 | Rackmount Server | Dell PowerEdge R210 | <TBD> | <TBD> |
| 9 | 24 | Rackmount Server | Dell PowerEdge R210 | 9NRC52S | <TBD> |
| 10 | 23 | Rackmount Server | Dell PowerEdge R410 | CDCPNBX | <TBD> |
| 11 | 20 | Rackmount Server | Dell PowerEdge R410 | 5673RBX | <TBD> |
| 12 | 19 | Rackmount Server | Dell PowerEdge R410 | HT4NWBX | <TBD> |
| 13 | 16 | Rackmount Server | Dell PowerEdge R410 | CW5TVBX | <TBD> |
| 14 | 15 | Rackmount Server | Dell PowerEdge R620 | FP56232 | <TBD> |
| 15 | 13 | Rackmount Server | Dell PowerEdge R430 | 5PVF8F2 | <TBD> |
| 16 | 12 | Rackmount Server | FUJITSU RX200 S7 | YLAQ018832 | <TBD> |
| 17 | 11 | Rackmount Server | FUJITSU RX200 S7 | YLAQ017333 | <TBD> |
| 18 | 10–1 | Blade Chassis | Lenovo Flex System Enterprise Chassis MT: 8721-HC1 | 06EDLHG | <TBD> |
| 19 | Bay 14 | Compute Node | Lenovo Flex System x240 M5 MT: 9532 | <TBD> | 58A1500458 |
| 20 | Bay 13 | Compute Node | Lenovo Flex System x240 M5 | <TBD> | 58A1500462 |
| 21 | Bay 11 | Compute Node | Lenovo Flex System x240 M5 | 06ENVTZ | <TBD> |
| 22 | Bay 10 | Compute Node | Lenovo Flex System x240 M5 | 06ENVTP | <TBD> |
| 23 | Bay 7 | Compute Node | Lenovo Flex System x240 M5 | <TBD> | 58A1500457 |
| 24 | Bay 6 | Compute Node | Lenovo Flex System x240 M5 | 06DFZET | <TBD> |
| 25 | Bay 3 | Compute Node | Lenovo Flex System x240 M5 | <TBD> | 58A1500464 |
| 26 | Bay 2 | Compute Node | Lenovo Flex System x240 M5 | 06ENVTT | <TBD> |
| 27 | ด้านข้าง 0U | Rack PDU | LIMAZ Monitored Input PDU LMZ-PMIP2C2T20N04 Feed A | 260300015 | <TBD> |
| 28 | ด้านข้าง 0U | Rack PDU | LIMAZ Monitored Input PDU LMZ-PMIP2C2T20N04 Feed B | <TBD> | <TBD> |

---

### ตาราง ข — การใช้งาน สถานะ และปลายทางการจัดเก็บ (ลำดับ # ตรงกับตาราง ก)

| # | เจ้าของ / ผู้ดูแลระบบ | บริการที่รันอยู่ | ระดับวิกฤต | สเปกฮาร์ดแวร์และดิสก์ภายใน | ปลายทาง | สภาพการทำงาน |
| :---- | :---- | :---- | :---- | :---- | :---- | :---- |
| 1 | ศูนย์คอมพิวเตอร์ SIT | Core Network Switch | C1 | สวิตช์หลักแกนกลางระดับ U42 | เก็บไว้ใช้ | ปกติ |
| 2 | ศูนย์คอมพิวเตอร์ SIT | Core Network Switch | C1 | สวิตช์หลักแกนกลางระดับ U39 | เก็บไว้ใช้ | ปกติ |
| 3 | ศูนย์คอมพิวเตอร์ SIT | ToR Switch | C1 | สวิตช์ 24G + 4x 10G SFP+, ยาว 364.5 มม. | เก็บไว้ใช้ | ปกติ |
| 4 | ศูนย์คอมพิวเตอร์ SIT | ToR Switch Gateway | C1 | สวิตช์ 24G + 4x 10G SFP+, ยาว 364.5 มม. | เก็บไว้ใช้ | ปกติ |
| 5 | ทีม Ivan | Proxmox VE 7.0.2 | C2 | Dell 1U Server, ยาว 394.3 มม., น้ำหนักสูงสุด 8.058 กก. | เก็บไว้ใช้ | ปกติ |
| 6 | ทีม Grace | Proxmox VE 9.2 | C2 | Dell 1U Server, ยาว 393.7 มม., น้ำหนักสูงสุด 8.058 กก. | เก็บไว้ใช้ | ปกติ |
| 7 | ทีม Judy | Proxmox VE 7.4-1 | C2 | Dell 1U Server, ยาว 394.3 มม., น้ำหนักสูงสุด 8.058 กก. | เก็บไว้ใช้ | ปกติ |
| 8 | ทีม Leo | Proxmox VE 9.2 | C2 | Dell 1U Server, ยาว 393.7 มม., น้ำหนักสูงสุด 8.058 กก. | เก็บไว้ใช้ | ปกติ |
| 9 | ทีม Mallory | Proxmox VE 8.4 | C2 | Dell 1U Server, ยาว 393.7 มม., น้ำหนักสูงสุด 8.058 กก. | เก็บไว้ใช้ | ปกติ |
| 10 | ทีม Quinn | Proxmox VE 9.2-1 | C2 | Dell 1U Server, ยาว 627 มม., น้ำหนักสูงสุด 15.9 กก. | เก็บไว้ใช้ | ปกติ |
| 11 | ทีม Charlie | Proxmox VE 7.4-1 | C2 | Dell 1U Server, ยาว 627 มม., น้ำหนักสูงสุด 15.9 กก. | เก็บไว้ใช้ | ปกติ |
| 12 | ทีม Victor | — | C3 | Dell 1U Server, ยาว 627 มม., น้ำหนักสูงสุด 15.9 กก. | เก็บไว้ใช้ | ชำรุด |
| 13 | ทีม Trent | Proxmox VE 7.4 | C2 | Dell 1U Server, ยาว 627 มม., น้ำหนักสูงสุด 15.9 กก. | เก็บไว้ใช้ | ปกติ |
| 14 | ทีม Alice | Proxmox VE 9.2.2 | C2 | Dell 1U Server, ยาว 701 มม., น้ำหนักสูงสุด 18.6 กก. | เก็บไว้ใช้ | ปกติ |
| 15 | ทีม Oscar | Proxmox VE 7.4-1 | C2 | Dell 1U Server, ยาว 607 มม., น้ำหนักสูงสุด 19.9 กก. (มีรางเฉพาะ) | เก็บไว้ใช้ | ปกติ |
| 16 | ทีม Ned | Proxmox VE 8.4 | C2 | Fujitsu 1U Server, ยาว 770 มม., น้ำหนักสูงสุด 18.0 กก. (มีรางเฉพาะ) | เก็บไว้ใช้ | ปกติ |
| 17 | ทีม Kevin | Proxmox VE 7.4 | C2 | Fujitsu 1U Server, ยาว 770 มม., น้ำหนักสูงสุด 18.0 กก. (มีรางเฉพาะ) | เก็บไว้ใช้ | ปกติ |
| 18 | คณะเทคโนโลยีสารสนเทศ SIT | Flex System Chassis | C1 | 6x 2500W PSU, 8x พัดลม, CMM MAC 40:F2:E9:BF:71:82 | เก็บไว้ใช้ | ปกติ |
| 19 | กลุ่มโครงงาน SRE | Proxmox VE Bay 14 | C2 | CPU Intel Xeon, 128GB RAM (4x 32GB LRDIMM), 2x 300GB SAS HDD, ยาว 500.54 มม. | เก็บไว้ใช้ | ปกติ |
| 20 | ทีม Frank | Compute Node | C2 | โมดูล x240 M5, ยาว 500.54 มม. | เก็บไว้ใช้ | ปกติ |
| 21 | ทีม Dave | Compute Node | C2 | โมดูล x240 M5, ยาว 500.54 มม. | เก็บไว้ใช้ | ปกติ |
| 22 | ทีม Eve | Compute Node | C2 | โมดูล x240 M5, ยาว 500.54 มม. | เก็บไว้ใช้ | ปกติ |
| 23 | ทีม Peggy | Compute Node | C2 | โมดูล x240 M5, ยาว 500.54 มม. | เก็บไว้ใช้ | ปกติ |
| 24 | ทีม Sybil | Compute Node | C2 | โมดูล x240 M5, ยาว 500.54 มม. | เก็บไว้ใช้ | ปกติ |
| 25 | ทีม Heidi | Compute Node | C2 | โมดูล x240 M5, ยาว 500.54 มม. | เก็บไว้ใช้ | ปกติ |
| 26 | ทีม Romeo | Compute Node | C2 | โมดูล x240 M5, ยาว 500.54 มม. | เก็บไว้ใช้ | ปกติ |
| 27 | ศูนย์คอมพิวเตอร์ SIT | Smart PDU Feed A | C1 | 32A 230V Single Phase, เต้ารับ C13 และ C19 | เก็บไว้ใช้ | ปกติ |
| 28 | ศูนย์คอมพิวเตอร์ SIT | Smart PDU Feed B | C1 | 32A 230V Single Phase, เต้ารับ C13 และ C19 | เก็บไว้ใช้ | ปกติ |

---

**สรุป** อุปกรณ์ทั้งหมด 28 รายการ · เก็บไว้ใช้ 27 รายการ · คืนพัสดุ 0 รายการ · ปลดระวาง/ชำรุดรอซ่อม 1 รายการ · ตำแหน่ง U ที่ว่าง 13 ตำแหน่ง


