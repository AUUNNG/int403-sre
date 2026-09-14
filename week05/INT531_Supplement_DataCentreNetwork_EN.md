# INT531: Site Reliability Engineering - Supplement
## Preparing the Network for the Data-Centre Room and the Containment Rack

School of Information Technology, King Mongkut's University of Technology Thonburi  
Supplement to Weeks 2 through 5 | 3-Hour Module or Modular Delivery | Content Updated: 2026  

---

## Table of Contents
1. [Overview and Learning Outcomes](#overview-and-learning-outcomes)
2. [Section 1: Cable Plant Architecture](#section-1-cable-plant-architecture)
3. [Section 2: Cable and Connector Types](#section-2-cable-and-connector-types)
4. [Section 3: Racks, Containment, and Cabling Discipline](#section-3-racks-containment-and-cabling-discipline)
5. [Section 4: Top of Rack (ToR) Switches and Uplink Design](#section-4-top-of-rack-tor-switches-and-uplink-design)
6. [Section 5: VLANs and IP Address Design](#section-5-vlans-and-ip-address-design)
7. [Section 6: Internet Path, Redundancy, and Acceptance](#section-6-internet-path-redundancy-and-acceptance)
8. [Applicable ISO/IEC 27001:2022 Security Controls](#applicable-isoiec-270012022-security-controls)
9. [Standards and Technical References](#standards-and-technical-references)
10. [Summary: This Supplement in Three Sentences](#summary-this-supplement-in-three-sentences)

---

## Overview and Learning Outcomes

This curriculum supplement covers physical layer cabling, access switch placement, thermal considerations, uplink oversubscription calculations, IP scheme design, and formal acceptance testing. Modules are structured in sequence from the hardest components to alter post-installation to the easiest:

1. Cable Plant Architecture
2. Cable and Connector Types
3. Racks, Containment, and Cabling
4. ToR Switches and Uplinks
5. VLANs and IP Design
6. Internet Path and Acceptance

### Supplement Learning Outcomes (SLO)
| Outcome Code | Description | Mapped Course Learning Outcome (CLO) |
| :--- | :--- | :--- |
| SLO N.1 | Explain standard cabling layers and choose a switch placement suited to room geometry | CLO4 |
| SLO N.2 | Select cable and connector types to match distance, transmission speed, and budget | CLO4 |
| SLO N.3 | Explain how airflow direction and cable dressing affect data centre cooling efficiency | CLO4, CLO5 |
| SLO N.4 | Compute uplink oversubscription ratios and evaluate operational acceptability | CLO5 |
| SLO N.5 | Design an integrated VLAN scheme and addressing plan for both IPv4 and IPv6 | CLO4 |
| SLO N.6 | Formally accept network installations against measurable criteria rather than link status lights | CLO4, CLO7 |

---

## Section 1: Cable Plant Architecture

### Core Principle
Physical structured cabling is installed once and maintained for a decade, whereas compute servers are replaced every 3 to 5 years. Cabling architecture must be rigorously planned before physical installation begins.

### Standard Cabling Hierarchy (TIA-942 and ISO/IEC 11801-5)
Standardized cabling architecture isolates structural trunk lines from localized server churn.

| Layer Code | Standard Name | Functional Responsibility | Lab Facility Implementation (CB-201) |
| :--- | :--- | :--- | :--- |
| **ER** | Entrance Room | Point where external provider cabling enters the building; establishes provider demarcation point. | Building central communications room |
| **MDA** | Main Distribution Area | Central aggregation hub of the data centre room; houses primary routers, core switches, and backbone patch fields. | Central core rack in room CB-201 |
| **HDA** | Horizontal Distribution Area | Intermediate distribution point for a specific server row; houses horizontal cross-connect patch panels. | Patch rack positioned at row end |
| **EDA** | Equipment Distribution Area | Server racks housing end equipment; serves servers via short in-rack patch runs. | Containment rack |
| **ZDA** | Zone Distribution Area | Optional consolidation point between HDA and EDA used when floor layouts fluctuate. | Not utilized in current deployment phase |

#### Architectural Advantage of Layering
Modular cabling layering ensures that server reconfigurations, rack additions, or equipment upgrades affect only short EDA patch runs. Permanent trunk cabling between MDA and HDA remains completely undisturbed.

### Access Switch Placement Strategies
The placement of the access layer switch dictates the copper-to-fiber ratio, cable tray congestion, and switch port utilization across the facility.

| Placement Model | Description and Topology | Key Advantages | Trade-offs and Disadvantages | Ideal Use Case |
| :--- | :--- | :--- | :--- | :--- |
| **Top of Rack (ToR)** | Dedicated access switches reside inside each server rack. | Extremely short copper patch cables contained within the rack; only 2 to 4 high-speed fiber uplinks leave the rack. | Lower port utilization if racks are partially filled; higher total switch count and management endpoints. | Rooms with consistently dense, fully populated racks. |
| **End of Row (EoR)** | Centralized high-density modular switches reside in a dedicated rack at the end of each row. | Maximum port utilization across the entire row; rack failure does not affect network switching infrastructure. | High-volume copper cable bundles running across overhead trays between racks; difficult cable maintenance. | Facilities with sparsely populated racks or heterogeneous hardware. |
| **Middle of Row (MoR)** | Centralized switches reside in the middle rack of the row. | Shorter average copper cable distances compared to EoR; preserves high port utilization. | Complex cable management; middle rack must accommodate significant cable convergence. | Balanced compromise between ToR and EoR for long server rows. |

#### Design Decision for CB-201 Containment Rack
The facility implements the **Top of Rack (ToR)** architecture:
- 20 distinct student laboratory groups require explicit physical and logical port isolation.
- All high-speed server copper patch cabling terminates locally within the containment rack.
- Only redundant optical fiber trunks exit the containment rack to reach the core MDA rack.

---

## Section 2: Cable and Connector Types

### Copper Twisted-Pair Cabling
Copper cabling selection is governed by channel length (including patch leads at both ends) and target transmission bandwidth.

| Specification | Supported Speeds | Maximum Channel Length | Application Guideline |
| :--- | :--- | :--- | :--- |
| **Cat5e** | 1 Gbps | 100 m | Obsolete for data centre environments; do not deploy in new installations. |
| **Cat6** | 1 Gbps at 100 m<br>10 Gbps limited to 37–55 m | 100 m (at 1 Gbps) | General low-bandwidth management workloads without 10 Gbps requirements. |
| **Cat6A** | 10 Gbps | 100 m | The standard recommended default for all modern copper infrastructure installations. |
| **Cat8** | 25 Gbps and 40 Gbps | 30 m | Short in-rack or adjacent-rack ToR server interconnects only. |

#### The Cat6 Limitation Caveat
While Cat6 is marketed as supporting 10 Gbps, its transmission distance is limited to 37–55 meters and is highly susceptible to alien crosstalk (electromagnetic coupling from adjacent twisted pairs in dense cable trays). Deploy **Cat6A** for guaranteed 10 Gbps transmission up to the full 100-meter channel limit.

### Optical Fiber Standards
Fiber selection is determined primarily by link distance, followed by transceiver budget.

| Fiber Standard | Core Type | Standard Jacket Color | Distance Reach (10G / 100G) | Operational Application |
| :--- | :--- | :--- | :--- | :--- |
| **OM3** | Multimode (50/125 µm) | Aqua | 300 m (10G) / 70 m (100G SR4) | Intra-room interconnects under 100 meters. |
| **OM4** | Multimode (50/125 µm) | Violet (Erika Violet) | 400 m (10G) / 100 m (100G SR4) | Most widely deployed standard for data centre horizontal runs. |
| **OM5** | Multimode (50/125 µm) | Lime Green | Similar to OM4; optimized for multi-wavelength SWDM | Environments planning Short Wavelength Division Multiplexing. |
| **OS2** | Singlemode (9/125 µm) | Yellow | 10 km to 40 km+ (10G LR / 100G LR4) | Inter-building campus backbones and external provider connections. |

#### Optical Connector Standards
- **LC Connector (Lucent Connector):** Small form-factor duplex connector utilizing a 1.25 mm ferrule. Standard interface for 1G, 10G, and 25G bidirectional transmission over a single fiber pair. Primary interface inside server racks.
- **MPO / MTP Connector (Multi-Fiber Push-On):** High-density array connector housing 8, 12, or 24 optical fibers in a single ferrule. Standard interface for 40GBASE-SR4 and 100GBASE-SR4 optics requiring 4 parallel transmit and 4 parallel receive lanes.
- **Transceiver Matching Rule:** Every optical run requires matching transceivers at both ends (e.g., 10GBASE-SR must terminate to 10GBASE-SR with identical wavelength specifications).

### Server-to-Switch Interconnect Technologies
Three technological approaches exist for connecting server NICs to the Top-of-Rack switch:

| Technology | Effective Distance | Relative Cost | Mechanical and Operational Constraints |
| :--- | :--- | :--- | :--- |
| **DAC (Direct Attach Copper)** | Up to 3–5 m (passive) | Lowest cost | Heavy, thick, and rigid; difficult to dress neatly; strict minimum bend radius. |
| **AOC (Active Optical Cable)** | 3 m to 30 m | Moderate cost | Connectors and optical transceivers permanently fixed; cannot detach or field-replace transceivers. |
| **Discrete Fiber + Transceivers** | 100 m to kilometers | Highest cost | Maximum routing flexibility; requires two transceivers per run verified for switch compatibility. |

#### Containment Rack Implementation
- **In-Rack Server Interconnects:** Deploy passive Direct Attach Copper (DAC) cables due to short physical distances (< 2 m) and significant cost savings.
- **ToR Uplinks:** Deploy discrete optical fiber with modular transceivers to support long-distance routing out of the containment rack to the central facility MDA.

---

## Section 3: Racks, Containment, and Cabling Discipline

### Core Principle
Rigorous cable management is not an aesthetic preference; it is a fundamental thermodynamic requirement for equipment cooling.

### Rear-of-Rack Cabling Discipline
The rear chassis space determines whether a rack functions reliably for a decade or degrades into thermal failure within six months.

```
       +-----------------------------------------+
       |             REAR RACK ELEVATION         |
       |                                         |
 LEFT  | [Power Tray]               [Data Tray]  | RIGHT
 TRAY  |   - PDU A Cabling            - DACs     | TRAY
       |   - PDU B Cabling            - Cat6A    |
       |                              - Fiber    |
       |                                         |
       |     ===============================     |
       |     [ SERVER EXHAUST AIR PATH ]         |
       |     (Keep Completely Unobstructed)      |
       |     ===============================     |
       +-----------------------------------------+
```

#### Four Rules of Cable Dressing
1. **Physical Segregation of Power and Data Trays:**
   - Power distribution runs exclusively on the left vertical cable tray; data and signal cables run exclusively on the right vertical tray.
   - Mitigates electromagnetic induction and allows technicians to service or replace power supplies without disturbing sensitive data lines.
2. **Precision Length Management:**
   - Pre-measure cables to exact lengths. Excess slack requires coiling, which consumes rack depth and severely restricts hot air exhaust discharge.
3. **Strict Adherence to Minimum Bend Radius:**
   - Copper cables: Minimum bend radius is 4 times the cable outer diameter.
   - Optical fiber: Minimum bend radius is 10 times the cable outer diameter.
   - Exceeding bend limits induces immediate insertion loss, packet corruption, or micro-fractures in glass cores.
4. **Two-Ended Identification Tagging (ANSI/TIA-606-C):**
   - Both ends of every patch cable must be labelled with source and destination rack, device, and port identifiers.
   - A single-ended label is functionally useless during troubleshooting when tracing disconnected leads.

#### Critical Airflow Warning
Never allow cables to drape horizontally across the rear exhaust vents of server chassis. Horizontal cable bundles act as thermal dams, trapping hot air inside the chassis, recirculating exhaust heat, and completely defeating containment infrastructure investments.

### Switch Airflow Direction
Network equipment airflow configuration is the most commonly overlooked detail during physical switch installation.

- **Port-Side Intake vs. Port-Side Exhaust:**
  - Standard servers pull cold air from the front aisle and exhaust heated air into the rear hot aisle.
  - If a switch with port-side intake is mounted facing the rear hot aisle, it ingests 35–45 degree C server exhaust air, triggering fan runaways, thermal throttling, and hardware failure.
- **Procurement Requirement:**
  - Airflow orientation is determined at purchase. Vendors manufacture Front-to-Back (Back-to-Front / Port-to-Power / Power-to-Port) variants under distinct part numbers. The ordered model must match the containment orientation.
- **Pre-Mounting Verification:**
  - Inspect chassis airflow directional arrows before securing mounting brackets. If an incorrect airflow unit is deployed, install the manufacturer-approved airflow ducting conversion kit rather than operating out of specification.

---

## Section 4: Top of Rack (ToR) Switches and Uplink Design

### Pre-Procurement Checklist for ToR Switches
Eight mandatory technical criteria to verify prior to procurement:

1. **Access Port Density and Speed:** Total server count multiplied by NIC ports per server, plus a minimum of 20% reserved expansion headroom.
2. **Uplink Port Bandwidth:** Calculate required oversubscription ratio first; size uplink bandwidth to satisfy target.
3. **Airflow Direction:** Airflow orientation must match hot/cold aisle containment architecture.
4. **Dual Redundant Power Supplies (PSU):** Two hot-swappable power supplies connected to independent PDU circuits (PDU A and PDU B).
5. **Chassis Depth Clearance:** Physical chassis depth must not obstruct vertical rear cable management channels.
6. **Dedicated Out-of-Band (OOB) Management Port:** Physical management interface completely isolated from data plane switching ASICs.
7. **Comprehensive IPv6 Feature Support:** Wire-speed IPv6 routing, Router Advertisement (RA) Guard, and DHCPv6 Snooping.
8. **Telemetry and Metric Streaming:** Native support for SNMP or gNMI telemetry streaming for automated scraping by Prometheus.

### Uplink Oversubscription Calculations
Oversubscription defines the ratio between total theoretical server access capacity and total uplink capacity connecting to the core network.

$$\text{Oversubscription Ratio} = \frac{\sum \text{Access Bandwidth}}{\sum \text{Uplink Bandwidth}}$$

#### Containment Rack Worked Calculation
- **Server-Side Access Bandwidth:**
  $$\text{Capacity}_{\text{server}} = 20 \text{ servers} \times 2 \text{ ports/server} \times 25 \text{ Gbps} = 1{,}000 \text{ Gbps}$$
- **Uplink Bandwidth:**
  $$\text{Capacity}_{\text{uplink}} = 2 \text{ ToR switches} \times 2 \text{ uplinks/switch} \times 100 \text{ Gbps} = 400 \text{ Gbps}$$
- **Calculated Ratio:**
  $$\text{Ratio} = \frac{1{,}000 \text{ Gbps}}{400 \text{ Gbps}} = 2.5 : 1$$

#### Workload Evaluation
- General data centre workloads comfortably tolerate an oversubscription ratio of approximately **3:1**.
- High-throughput, storage-intensive, or distributed AI/ML workloads demand ratios under **2:1**.
- A ratio of **2.5:1** is acceptable for general instructional workloads.

#### Redundancy and Failure Mode Analysis ($N-1$ Scenario)
If one ToR switch suffers catastrophic failure, available uplink capacity drops by 50% (from 400 Gbps to 200 Gbps). The effective oversubscription ratio jumps to:

$$\text{Degraded Ratio} = \frac{1{,}000 \text{ Gbps}}{200 \text{ Gbps}} = 5 : 1$$

System architects must verify that degraded operations under single-switch failure remain acceptable to running workloads without inducing buffer collapse.

---

## Section 5: VLANs and IP Address Design

### Core Principle
An effective addressing architecture is self-documenting: observing an IP address or VLAN ID should immediately convey network tier, role, and tenant ownership without consulting a database.

### Room-Level VLAN and Addressing Allocation

| VLAN ID | Designated Purpose | Allocated IPv4 Subnet | Allocated IPv6 Subnet | Routing Profile |
| :--- | :--- | :--- | :--- | :--- |
| **101–120** | Student Workgroups 1 through 20 | `10.20.G.0/24` *(where G = group ID 1–20)* | `2001:db8:a:1xx::/64` *(e.g., VLAN 101 = 2001:db8:a:101::/64)* | Routed to internal core |
| **250** | Network Infrastructure Management | `10.20.250.0/24` | `2001:db8:a:250::/64` | Restricted; internal ACL only |
| **251** | High-Speed Storage Network | `10.20.251.0/24` | `2001:db8:a:251::/64` | Non-routed; intra-rack only |
| **254** | Out-of-Band Management (OOB / IPMI) | `10.20.254.0/24` | `fd00:20:254::/64` *(Unique Local Address)* | Completely isolated |
| **999** | Unused Ports (Blackhole / Parking) | *Unassigned* | *Unassigned* | Administrative shutdown |

#### Switch Port Security Hygiene
Every unused physical switch port must be assigned to **VLAN 999** and placed in an administrative shutdown state (`shutdown`). Leaving unassigned ports active in a default VLAN (such as VLAN 1) creates an unmonitored physical ingress point into the production network.

### IPv4 Subnet Sizing Architecture
Subnet sizing must account for bare-metal hosts, management interfaces, hypervisors, and container instances.

1. **Host Capacity Projection per Workgroup:**
   - 1 physical server + 1 management interface + ~20 container/virtual instances = approximately 25 IP addresses.
2. **Subnet Prefix Selection:**
   - A `/27` subnet provides 30 usable host addresses. While sufficient mathematically, it offers negligible headroom for expansion.
   - Selecting `/24` (254 usable addresses) provides ample headroom, standardizes subnet masks, and simplifies firewall rule definitions.
3. **Room Allocation Strategy:**
   - Supernet block `10.20.0.0/16` is partitioned into `/24` subnets.
   - Workgroups 1 to 20 map to `10.20.1.0/24` through `10.20.20.0/24`.
   - Core infrastructure reserves `10.20.250.0/24` to `10.20.254.0/24`.
   - Subnets `10.20.21.0/24` through `10.20.249.0/24` remain reserved for unallocated growth.

*The Golden Sizing Rule:* Always size subnets one power of two larger than initial calculations suggest. Resizing an active subnet post-deployment requires whole-room re-addressing and routing table updates.

### IPv6 Addressing Architecture
IPv6 design departs from IPv4 conservation patterns and emphasizes hierarchical alignment:

- **Universal `/64` Allocation:** Every VLAN receives a `/64` subnet. This prefix length is mandatory for Stateless Address Autoconfiguration (SLAAC; RFC 4862). Subnetting smaller than `/64` breaks core IPv6 operational features.
- **Faculty `/48` Supernet Allocation:** The university network assigns a `/48` prefix, providing 65,536 discrete `/64` subnets—more than sufficient for enterprise scaling.
- **Deterministic Subnet-to-VLAN Mapping:** Subnet identifiers mirror VLAN tags directly:
  - VLAN 101 maps to `2001:db8:a:101::/64`
  - VLAN 120 maps to `2001:db8:a:120::/64`
  - An engineer reading the IPv6 prefix immediately identifies the VLAN.
- **Unique Local Addresses (ULA):** Use ULA prefixes (`fd00::/8`; RFC 4193) strictly on non-routed management tiers such as the Out-of-Band IPMI network. Production networks must utilize routable Global Unicast Addresses (GUA) without network address translation (NAT).
- **Address Assignment Strategy:**
  - Servers and switches: Static address assignment.
  - Ephemeral client nodes: Stateless Address Autoconfiguration (SLAAC).
  - Controlled enterprise endpoints: Stateful DHCPv6 for audit trails and lease logging.

#### Mandatory IPv6 Layer 2 Security
Every IPv6 interface automatically configures a link-local address (`fe80::/10`) upon link initialization, even if IPv6 is not actively configured. Switches must enforce:
- **Router Advertisement (RA) Guard:** Drops rogue or unauthorized RA packets originating from untrusted access ports to prevent rogue default gateway attacks.
- **DHCPv6 Snooping:** Intercepts unauthorized DHCPv6 server advertisements across access edge ports.

### Out-of-Band (OOB) Management Architecture
The management network is the recovery tool required when the primary network fails.

- **Physical Isolation:** The OOB network utilizes physically separate switching hardware, isolated patch panels, and distinct cabling channels from the data plane.
- **Connected Interfaces:** Server IPMI / iDRAC / BMC ports, network switch console and management ports, serial console terminal servers, and switched smart PDUs.
- **Security Posture:** Access must be restricted via tight access control lists (ACLs), mandatory multi-factor authentication, and continuous session audit logging.

---

## Section 6: Internet Path, Redundancy, and Acceptance

### Campus Core Interconnect Specifications
Five architectural parameters must be formally ratified with campus network engineering:

1. **Egress Redundancy and Diverse Routing:** Single uplink paths represent critical single points of failure (SPOF). Ensure dual egress links exit the facility via physically separate wall penetrations and non-overlapping underground conduits.
2. **NAT Translation Boundaries:** Identify precisely which upstream routing layer performs Network Address Translation. Unrecorded NAT boundaries complicate distributed trace context analysis and IP audit logs.
3. **Firewall Perimeter Placement:** Establish whether inter-VLAN communications are routed locally at the ToR/core switch or forced across a stateful firewall inspection engine, which may bottleneck intra-rack east-west throughput.
4. **Committed Bandwidth SLAs:** Secure documented upstream bandwidth guarantees validated through empirical load testing rather than shared verbal assumptions.
5. **Authoritative DNS and NTP Infrastructure:** Establish shared, highly available campus NTP sources to prevent cross-system clock skew and preserve incident log chronology.

### Measurable Network Acceptance Criteria
Network installation cannot be accepted based merely on green physical link lights. Eight empirical criteria must pass verification:

| Check ID | Verification Criterion | Verification Methodology | Responsible Authority |
| :--- | :--- | :--- | :--- |
| **NAC-1** | Permanent link certification passed | Cable analyzer certification report exported and archived in project repository | Cabling Contractor |
| **NAC-2** | Port speed and duplex auto-negotiation | Switch CLI confirms full speed (e.g., 25G / 100G) and full-duplex operation on all active ports | Technical Reviewer |
| **NAC-3** | Zero interface error counters | Switch interface counters confirm 0 CRC errors, 0 input drops, and 0 frame alignment errors after 24 hours of sustained operation | Technical Reviewer |
| **NAC-4** | VLAN segmentation and isolation | Positive connectivity tests verify intra-VLAN traffic; negative connectivity tests confirm isolated VLANs cannot communicate without routing | Change Owner |
| **NAC-5** | IPv4 and IPv6 plan compliance | Network endpoints, gateways, and switches verify IP allocation matching approved design document | Change Owner |
| **NAC-6** | Out-of-band network resilience | Primary data path physically disconnected; verify OOB network maintains complete remote management access | Safety Officer |
| **NAC-7** | NTP time synchronization | All switches, servers, and hypervisors synchronize to authoritative NTP with clock offset under 1.0 second | Technical Reviewer |
| **NAC-8** | Automated metric ingestion | Prometheus successfully scrapes switch SNMP/gNMI targets with telemetry reporting metric `up == 1` | Change Owner |

#### The Importance of Error Counter Audits (NAC-3)
A damaged optical fiber or poorly terminated Cat6A cable will frequently illuminate physical link lights and transmit baseline traffic, while silently dropping packets under load and accumulating Cyclic Redundancy Check (CRC) errors. Rigorous acceptance requires auditing interface error counters after a continuous 24-hour test period.

---

## Applicable ISO/IEC 27001:2022 Security Controls

Network architecture and cabling operations must conform to international information security standards:

| Control Identifier | Control Title | Implementation Requirement in Data Centre Network |
| :--- | :--- | :--- |
| **A.8.20** | Networks Security | Network infrastructure is actively monitored, controlled, and protected; configuration logs are centralized and retained. |
| **A.8.21** | Security of Network Services | Upstream service agreements, egress capacity, and routing boundaries are formally documented with the provider. |
| **A.8.22** | Segregation of Networks | Student group VLANs, storage networks, production traffic, and out-of-band management networks are strictly segmented. |
| **A.7.12** | Cabling Security | Telecommunications and power cabling are physically protected against interception, physical damage, and inductive interference. |
| **A.8.16** | Monitoring Activities | Continuous monitoring of network traffic volumes, error rates, and security telemetry for anomalous operational behavior. |
| **A.5.14** | Information Transfer | Rules, cryptographic mechanisms, and operational procedures protecting data transmission in transit across network segments. |

---

## Standards and Technical References

### Cabling and Data Centre Infrastructure Standards
- **ANSI/TIA-942-B:** *Telecommunications Infrastructure Standard for Data Centers*.
- **ISO/IEC 11801-5:** *Information technology — Generic cabling for customer premises — Part 5: Data centres*.
- **ANSI/TIA-568-D:** *Balanced Twisted-Pair Telecommunications Cabling and Components Standard*.
- **ANSI/TIA-606-C:** *Administration Standard for Telecommunications Infrastructure* (Labelling standards).
- **EN 50174-2:** *Information technology — Cabling installation — Part 2: Installation planning and practices inside buildings*.

### Internet Protocol and Network Security Standards
- **RFC 4291:** *IP Version 6 Addressing Architecture*.
- **RFC 4193:** *Unique Local IPv6 Unicast Addresses (ULA)*.
- **RFC 6434 / RFC 8504:** *IPv6 Node Requirements*.
- **RFC 7454:** *BGP Operations and Security* (Edge routing security guidelines).
- **RFC 3849:** *IPv6 Address Prefix Reserved for Documentation* (Use of `2001:db8::/32`).
- **ISO/IEC 27001:2022:** *Information security, cybersecurity and privacy protection — Information security management systems*.

---

## Summary: This Supplement in Three Sentences
1. Structural cabling infrastructure is laid once and remains in service for a decade while compute nodes turn over every five years; design the cable plant with greater capacity headroom than initial calculations suggest.
2. Rear-of-rack cable dressing is an operational airflow imperative rather than cosmetic tidiness; improper cable bundles obstructing hot air exhaust undermine the entire containment cooling infrastructure.
3. A resilient VLAN and IP addressing architecture is self-documenting and provides sufficient subnet headroom so that room growth never mandates a whole-room network re-architecture.
