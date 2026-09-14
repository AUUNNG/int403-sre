# INT 403 / INT 531: Site Reliability Engineering

## Week 1: Introduction to SRE and the Idea of Reliability

- Course: INT 403 / INT 531 Site Reliability Engineering
- Focus: Designing, measuring and running systems that stay up
- Institution: School of Information Technology, King Mongkut's University of Technology Thonburi
- Format: Lecture 2 h + Lab 2 h | Content updated 2026

---

## Session Learning Outcomes (SLOs)

By the end of this session you will be able to:

- SLO 1.1: Explain where SRE came from and why it emerged at large-system scale (CLO1)
- SLO 1.2: Compare SRE, DevOps, Platform Engineering, and classic system administration (CLO1)
- SLO 1.3: Define toil, sort work into toil or engineering, and explain the 50% ceiling (CLO1)
- SLO 1.4: Explain in economic terms why 100% reliability is the wrong target (CLO1)
- SLO 1.5: Produce an infrastructure change plan that references a recognised security standard (CLO3, CLO7)

---

## Agenda Overview

1. Why SRE exists: A real outage, its blast radius, and what failure costs
2. What SRE actually is: Definition, principles, and how it differs from DevOps and classic ops
3. How reliability gets measured: The price of each nine, and why 100% is the wrong target
4. Toil and the work that should disappear: The six tests, and the 50% ceiling on operational work
5. SRE in 2026 and the FDE career: Five trends, plus the Forward Deployed Engineer role
6. Lab 1 — Moving racks into containment: Planning real work in the data centre against ISO/IEC 27001

---

## Prerequisite Context: Active Learning and Data Centre Baseline

Photos and lab activities from previous coursework demonstrate the baseline physical infrastructure environment:
- Physical server racks in the Taxila Room.
- Hardware unboxing, physical server rack assembly, server installation (Lenovo console terminal), and cable routing.
- Airflow dynamics: Understanding cold aisle and hot aisle layouts, identifying where hot air exhausts and recirculates, and planning containment structures.

---

## Section 01: Why SRE Exists

Reliability is never free. Large-scale software systems face cascading failures where a tiny defect triggers global outages.

### Case Study: The AWS us-east-1 Outage of 20 October 2025

One small defect turned into a global event.

#### Key Metrics

| Metric | Value | Details |
| :--- | :--- | :--- |
| Recovery Duration | ~15 hours | Time until every service was fully recovered |
| Scope of Impact | 140+ AWS services | Wide blast radius affecting internal tools and external customers |
| Root Cause | 1 bug | A race condition in automated DNS management |
| Financial Impact | ~$581M | Estimated insured losses |

#### Timeline of Events

- 23:48: Automated DNS management for DynamoDB overwrote itself, wiping the DNS records for the service endpoints.
- 00:38: Engineers identified the DNS fault, but the automation could not repair itself; records had to be fixed manually by hand.
- 02:25: DynamoDB returned to service, but services that depended on it kept failing in a cascading chain.
- 14:20: Everything recovered. The time spent recovering was several times the time spent fixing the root cause.

Sources: AWS post-event summary; ThousandEyes, AWS Outage Analysis (Oct 2025); CyberCube (loss estimate).

### Four Lessons That Recur Across the Curriculum

1. Dependencies fail in chains (Weeks 3 and 12)
   - AWS's own internal services depended on DynamoDB, so the tools needed to fix the outage were broken too.
   - Core concepts: Cascading failure and control-plane dependency.
2. Automation that cannot repair itself (Week 7)
   - Automation without safety guards does damage faster than a human can.
   - The team had to disable automated systems and repair DNS records manually.
3. Recovery is harder than the original failure (Week 15)
   - The root cause was fixed in approximately 3 hours, but it took another 12 hours to drain queued backlogs, handle thundering herds, and restore all dependent systems.
4. Transparency builds trust (Week 16)
   - AWS published a detailed public post-event summary and analysis, allowing the industry to learn from the failure.
   - Core concept: Blameless postmortem.

### The Landscape in 2026: The Pressure is Rising

Data and forecasts as of mid-2026:

- Outages recorded in H1 2026: 30,246 across 1,082 providers spanning cloud, SaaS, AI, payments, and observability tooling (Source: IncidentHub).
- 2026 Forecast: Forrester expects at least two multi-day hyperscaler outages this year, as cloud providers shift capital expenditure toward AI data centres and away from maintaining older infrastructure.
- Daily AI usage among developers: 90%. DORA 2025 found that AI increases delivery throughput, but simultaneously raises delivery instability.

#### Failure Modes Unique to 2026

- Physical and geopolitical risk: AWS reported that data centres in the Middle East took physical damage from regional conflict.
- AI providers became critical production dependencies: A single LLM outage disrupted education platforms, developer tooling, and customer support channels simultaneously.
- Provider's own automation as the failure cause: An automated account suspension erroneously triggered, leaving an enterprise customer with almost nothing running.
- Cloud concentration risk: Now viewed as a regulatory and systemic compliance concern, not just an architectural/technical issue.

---

## Section 02: What SRE Actually Is

Moving from operations executed manually by hand to an engineering problem solved with software, code, and data.

### Origin and Definition

Formulated at Google in 2003 by Ben Treynor Sloss:

> Ben Treynor Sloss described SRE as what you get when software engineers design and run the operations function, instead of hiring more system administrators as the system grows.

### The Problem, The Mindset, and The Target State

| Dimension | Description |
| :--- | :--- |
| The Problem to Solve | - System load and scale grow tenfold, while headcount cannot.<br>- Manual operations work scales linearly with load.<br>- Development teams (incentivized to push changes) and operations teams (incentivized to maintain stability) are pulled toward opposing goals. |
| How SRE Thinks | - Treat running production systems as a software engineering problem.<br>- Make operational decisions based on objective data and metrics, not intuition or seniority.<br>- Accept risk at an explicit, calculated level established in advance. |
| What Good Looks Like | - Operational overhead grows sublinearly relative to system scale.<br>- Developers and SREs share common reliability targets via Service Level Objectives (SLOs) and Error Budgets.<br>- Sustainable on-call rotations that prevent engineering burnout. |

### Comparative Analysis: Traditional Ops, DevOps, SRE, and Platform Engineering

None of these paradigms replaces the others; they answer different questions within the organization.

| Dimension | Traditional Ops | DevOps | SRE | Platform Engineering |
| :--- | :--- | :--- | :--- | :--- |
| Core Question | Is the system still up? | How do we ship faster and more often? | Is the system reliable enough, and how do we know? | How do we let other teams do this themselves? |
| Nature / Structure | A culture and set of operational practices | A culture and set of collaboration practices | A specific job title and defined engineering role | A job title and internal product team |
| Headline Metric | Uptime and ticket resolution counts | The four DORA metrics (Deployment Frequency, Lead Time for Changes, Change Failure Rate, Failed Deployment Recovery Time) | SLOs and error budgets | Developer Experience (DevEx) and platform adoption rate |
| What Gets Delivered | Firefighting manual fixes | CI/CD delivery pipelines and shared cultural alignment | Code, production automation, and SLO frameworks | Internal Developer Platform (IDP) and self-service capabilities |

*Conceptual Note:* "Class SRE implements DevOps" — SRE provides concrete, programmatic, and measurable mechanisms to implement the cultural philosophy of DevOps.

### The Seven Principles of SRE

| Principle | Core Concept | Curriculum Reference |
| :--- | :--- | :--- |
| 1. Embracing Risk | Take calculated, quantified risks rather than pursuing unattainable perfection. | Week 2 |
| 2. Service Level Objectives (SLOs) | Establish reliability targets measured from the user's perspective, not purely internal server-side telemetry. | Week 2 |
| 3. Eliminating Toil | Replace manual, repetitive operational tasks with software and automation. | Week 7 |
| 4. Monitoring & Observability | If you cannot observe and explain system behavior, you cannot reliably operate it. | Weeks 4–5 |
| 5. Automation | Automation requires bounded limits, rate limiting, and emergency stop mechanisms. | Week 7 |
| 6. Release Engineering | Software releases must be repeatable, verifiable, and quickly reversible (rollback). | Week 10 |
| 7. Simplicity | Unnecessary architectural complexity constitutes reliability debt. | Week 12 |

#### The Hard Line: The 50% Rule

An SRE team spends no more than 50% of its working time on operational toil (tickets, manual tasks, repetitive maintenance). The remaining 50% must be dedicated to engineering work (writing code, building automation, architectural improvements) that systematically eliminates future toil.

*Operational Reality:* The 50% ceiling is difficult to maintain in practice because legacy organizations measure operations by tickets closed rather than tickets eliminated or prevented.

---

## Section 03: How Reliability is Measured

Before improving reliability, stakeholders must agree on an objective standard for what constitutes "good enough."

### The Cost of Each Nine: Downtime Allowance

Downtime budget per 30-day window across availability tiers:

| Availability Target ("Nines") | Allowed Downtime per 30 Days | Typical Target Systems |
| :--- | :--- | :--- |
| 99% (Two Nines) | 7.2 hours | Internal, non-critical background systems |
| 99.9% (Three Nines) | 43.2 minutes | General-purpose business services |
| 99.95% | 21.6 minutes | Customer-facing systems with external users |
| 99.99% (Four Nines) | 4.3 minutes | High-value payments and financial transaction systems |
| 99.999% (Five Nines) | 26 seconds | Critical telecommunications and carrier infrastructure |

#### Critical Mathematical and Operational Realities

1. Exponential cost curve: Each additional nine decreases allowed downtime tenfold, but achieving it typically costs exponentially more due to active redundancy, automated failover, and multi-region synchronization.
2. Multiplicative degradation in series: Sequential dependent components reduce overall reliability below that of the weakest link:
   $$A_{\text{total}} = A_1 \times A_2 \times A_3$$
   For three services chained together, each with 99.9% availability:
   $$0.999 \times 0.999 \times 0.999 \approx 0.997 \text{ (99.7\%)}$$
   Allowed downtime increases from 43.2 minutes to over 2.1 hours per month.
3. User perception vs. raw metrics: Users experience outage timing, duration, and context rather than an aggregate percentage. An outage of 43 minutes at 03:00 AM on a Sunday is imperceptible to most users, whereas a 43-minute outage during course registration day is disastrous.

### Why 100% Reliability is the Wrong Target

- Fact 1: Users never experience 100% reliability.
  The connection path between user and backend includes smartphones, local Wi-Fi, ISP transit, mobile networks, and recursive DNS. If client-side network reliability is 99.6%, engineering backend reliability from 99.99% to 99.999% provides zero perceptible benefit to the user.
- Fact 2: The final nine consumes resources needed for product innovation.
  Engineering time, infrastructure budget, and personnel are finite. Squeezing out the last fraction of a percent diverts engineering hours away from developing high-impact product features. Reliability is a balanced business decision, not an exercise in technical perfectionism.

#### Differentiated Reliability Targets within an Organization

| System | Availability Target | Business & Architectural Context |
| :--- | :--- | :--- |
| Course Registration | 99.95% | 10 minutes of downtime on registration day prevents thousands of students from securing required courses; demands automated fallbacks, load shedding, and pre-semester stress rehearsals. |
| Learning Management System (LMS) | 99.9% | Nighttime downtime causes the greatest harm because students submit assignments before midnight deadlines; SLOs should vary dynamically by time-of-day. |
| Faculty Public Information Website | 99.0% | Several hours of daytime unavailability causes minimal disruption; expensive multi-region hot-standby architectures are not economically justified. |

---

## Section 04: Toil and Operational Debt

> Being busy is not the same as being useful.

### Definition of Toil

Toil is operational work tied to running a production service that is manual, repetitive, automatable, tactical, devoid of enduring value, and scales linearly as the service grows.

### The Six Tests of Toil

To classify an operational task as toil, evaluate it against six criteria:

1. Manual (ทำด้วยมือ): The work is performed by human hands rather than executed by software.
2. Repetitive (ทำซ้ำ ๆ): The task is performed repeatedly without novel problem-solving.
3. Automatable (เขียนโปรแกรมแทนได้): The process follows deterministic rules that could be codified into software.
4. Tactical (แก้เฉพาะหน้า): The action addresses an immediate symptom without resolving underlying structural causes.
5. No Enduring Value (ไม่เหลือคุณค่าถาวร): Once completed, the system state is essentially identical to before the issue occurred; the system is no more robust.
6. Scales Linearly (โตตามขนาดระบบ): Work volume expands directly in proportion to system load, number of users, or cluster size.

### Real-World Examples: School Data Centre

| Data Centre Task | Classification | Rationale |
| :--- | :--- | :--- |
| Resetting individual user passwords via an admin console | Toil | Manual, repetitive, automatable via self-service identity management. |
| Restarting a crashed service every Monday morning | Toil | Tactical workaround; does not resolve root-cause memory leak or crash bug. |
| Manually writing serial numbers on paper and retyping into spreadsheets | Toil | Purely manual data entry; automatable via network discovery or barcodes. |
| Plugging physical console cables into each box to check firmware versions | Toil | Scales linearly with physical machine count; automatable via BMC/IPMI scripts. |
| Copying PUE readings manually off UPS displays into monthly reports | Toil | Repetitive manual logging; automatable via SNMP or Modbus telemetry scrapers. |
| Designing containment layouts, automating firmware deployment, or postmortem analysis | Engineering (Not Toil) | Requires human judgment, produces permanent system improvements, done once. |

---

## Section 05: SRE in 2026 and Career Evolution

### Five Major Trends Shaping SRE in 2026

1. AI amplifies; it does not fix:
   - DORA 2025 research indicates AI improves software delivery velocity, but simultaneously increases delivery instability. Teams with robust deployment and testing foundations excel, whereas teams with weak fundamentals experience amplified system failures.
   - Core practice: Solidify SLOs, automated rollback, and canary analysis prior to accelerating deployment velocity.
2. AI providers represent critical production dependencies:
   - Third-party LLM APIs now reside on the critical user request path. Provider downtime immediately impairs dependent client applications globally.
   - Core practice: Implement aggressive client-side timeouts, fallback models/heuristics, circuit breakers, and graceful degradation strategies.
3. Rise of Platform Engineering:
   - Organizations create internal platforms allowing software developers to self-service application deployments safely. SRE shifts from manual gatekeeping to architecting the "Golden Path."
   - Core practice: Treat internal developer platforms as products with distinct internal user personas.
4. OpenTelemetry (OTel) as the universal telemetry standard:
   - Metric, log, and trace ingestion has converged onto vendor-neutral OpenTelemetry standards, eliminating proprietary vendor lock-in.
   - Core practice: Implement standardized OTel instrumentation across application runtimes.
5. Physical cost and power constraints:
   - Explosive growth in AI model training and inference has constrained power availability, rack physical space, and cooling capacity.
   - Core practice: Adopt FinOps cost control, track Power Usage Effectiveness (PUE), and implement strict thermal containment.

### The Emerging Role: Forward Deployed Engineer (FDE)

An engineer who embeds directly within the customer's technical environment and takes end-to-end ownership of the system from day-one deployment through long-term production operations.

```
[ Core Product Engineering ]
         |
         | (Builds core platform & foundation model)
         v
[ Forward Deployed Engineer (FDE) ] <=======> [ Customer Environment ]
  - Embeds on-site / hands-on                   - Customer infrastructure
  - Writes production code on real data         - Real customer data & constraints
  - Owns operational delivery & reliability     - Security policies & enterprise users
         |
         +-----> (Feeds real failure modes back into Core Roadmap)
```

- Accountability: "Whoever scoped the system on day one gets paged when it breaks in month six."
- History: Pioneered by Palantir around 2005; widely adopted by 2026 by AI enterprises including OpenAI, Anthropic, Google Cloud, Databricks, Salesforce, and Scale AI.
- Distinction: Traditional consultants deliver slides and recommendation reports; FDEs deliver functioning, production-grade software running in customer environments.

### Comparative Matrix: Adjacent Technical Roles

| Metric / Dimension | Management Consultant | Solutions Engineer (SE) | Forward Deployed Engineer (FDE) | Site Reliability Engineer (SRE) |
| :--- | :--- | :--- | :--- | :--- |
| Deliverable | Slide decks, assessment reports, strategic recommendations | Configuration and demo of off-the-shelf software | Production code and live systems deployed on customer infrastructure | Automation software, SLO frameworks, and resilience tooling |
| Incident Responsibility | Never paged; engagement concludes upon report submission | Hands off operational issues to customer support | Original deployment engineer is paged during live production outages | On-call rotation managing the service error budget |
| Customer Presence | High (~80% client-facing) | Moderate (~40-60% pre-sales) | Embedded on-site (~50% customer-facing) | Internal-facing (~10-20% customer contact) |

### 2026 Market Metrics for FDE Roles

- Job Listing Growth: ~800% year-over-year increase in job postings.
- Base Compensation: $160,000 – $280,000 mid-level base salary range at frontier AI labs (e.g., OpenAI San Francisco).
- Customer Site Time: Approximately 50% of working time spent embedded directly with customer teams.

### Preparing for SRE / FDE Roles While in University

1. Ship to Real Production: Deploy real, live software systems with authentic end users, complete with alerts that wake you when systems fail, rather than toy demo projects.
2. Deconstruct Ambiguous Problems: Technical interviews evaluate the ability to clarify underspecified requirements and edge cases prior to writing code, rather than pure algorithmic memorization.
3. Cross-Disciplinary Communication: Ability to articulate architectural trade-offs, risks, and technical failures to non-technical business stakeholders is tested equally with technical competency.
4. Master Reliability Engineering: In-depth understanding of SLOs, error budgets, observability, tracing, automated rollbacks, and postmortem methodologies.

---

## Section 06: Lab 1 — Moving Racks into Containment

Applying SRE principles, physical engineering, and compliance rigor to real data centre infrastructure using the ISO/IEC 27001:2022 framework.

### The Physical Challenge

Transition infrastructure from legacy open racks into a modern enclosed containment aisle:

- Current State: Open racks in continuous operation since previous terms; mixed hardware generations; outdated asset inventory; uncontrolled mixing of hot exhaust and cold supply airflow.
- Target State: Sealed hot and cold aisle containment; elimination of air recirculation; improved Power Usage Effectiveness (PUE); support for high power density per rack.
- Operational Constraints: Zero downtime permitted for critical school services during operational hours; physical moves must execute during out-of-hours maintenance windows; full reversibility required.

### Why Physical Rack Migration is SRE Work

1. Change Management: Structured execution plans, explicit approval workflows, and designated change owners.
2. Blast Radius Assessment: Analyzing dependencies to determine exactly which services fail if a particular circuit or switch is disconnected.
3. Rollback Planning: Strict time-bound procedures to restore original operational state if newly migrated hardware fails to boot.
4. Asset Inventory: Maintaining complete visibility over physical assets to enable rapid recovery and compliance auditing.

### Physics and Engineering of Aisle Containment

In open-rack setups, hot exhaust air recirculates around the tops and sides of racks, as well as through unsealed U slots, re-entering server front intakes. This elevates intake temperatures above thermal design thresholds, forcing cooling compressors to run continuously at peak energy consumption without lowering internal rack temperatures.

#### Key Containment Rules

1. Air Separation: Containment physically isolates cold supply air from hot exhaust air.
2. Blanking Panels: Every unused rack unit (U) must be sealed with a blanking panel. Empty rack units act as shortcuts for hot exhaust recirculation.
3. Efficiency Impact: Decreases facility PUE and allows higher computational density per square metre.

---

## Lab Compliance Framework: ISO/IEC 27001:2022 Annex A Mapping

Every activity performed in the data centre lab maps directly to international security and operational controls:

| Control ID | Control Name | Specific Lab Implementation |
| :--- | :--- | :--- |
| A.5.9 | Inventory of information and associated assets | Perform complete audit of all devices in the legacy rack, detailing serial numbers, rack U positions, system owners, and hosted services. |
| A.5.37 | Documented operating procedures | Draft a step-by-step Method of Procedure (MOP) with explicit execution timelines that external engineers can follow. |
| A.7.4 | Physical security monitoring | Maintain strict physical access logs of all individuals entering and exiting the data centre; supervise external personnel. |
| A.7.8 / A.7.12 | Equipment siting and protection, cabling security | Design target rack elevation: map precise U allocations, enforce separation of power from high-speed data cabling, and ensure proper cable radius. |
| A.7.10 / A.7.14 | Storage media and secure disposal / re-use | Establish secure wiping procedures with verifiable evidence for decommissioned storage drives prior to hardware disposal. |
| A.7.11 | Supporting utilities | Verify electrical load balance across 3-phase circuits, UPS battery runtime capacity, and HVAC thermal load prior to equipment transfer. |
| A.8.32 | Change management | Submit formal Change Request specifying operational impact, blast radius, rollback triggers, and approver authorizations. |

---

## The Migration Plan: Five Execution Phases

```
[ Phase 1: Survey & Inventory ] (A.5.9)
         |
         v
[ Phase 2: Analyse Dependencies & Risk ] (A.8.32)
         |
    (In-Class Milestone)
         |
         v
[ Phase 3: Design New Rack Layout ] (A.7.8 / A.7.11)
         |
         v
[ Phase 4: Write MOP & Rollback Plan ] (A.5.37)
         |
         v
[ Phase 5: Rehearse & Peer Review ] (A.5.37)
```

1. Phase 1: Survey and Inventory (In-Class)
   - Method: Inspect the legacy rack unit by unit (U1 to U42). Document manufacturer, model, hardware serial number, U location, power consumption, network port utilization, and hosted workloads.
   - Deliverable: Complete Asset Inventory Sheet (mapped to ISO control A.5.9).
2. Phase 2: Dependency and Risk Analysis (In-Class)
   - Method: Trace upstream and downstream dependencies. Identify single points of failure (SPOFs), assess blast radius if specific hardware is isolated, and assign criticality rankings.
   - Deliverable: Dependency Graph and Risk Register (mapped to ISO control A.8.32).
3. Phase 3: Target Rack Elevation Design (Out-of-Class)
   - Method: Model hardware placement within the new containment rack, optimizing for weight distribution, thermal airflow, three-phase power balancing, and cable distance.
   - Deliverable: Rack Elevation Diagram (mapped to ISO controls A.7.8 and A.7.11).
4. Phase 4: Method of Procedure (MOP) & Rollback Plan (Out-of-Class)
   - Method: Author a procedural runbook including itemized time estimates, role assignments, health check verification milestones, and unambiguous abort criteria.
   - Deliverable: Formal MOP and Rollback Document (mapped to ISO control A.5.37).
5. Phase 5: Tabletop Rehearsal and Peer Review (Out-of-Class)
   - Method: Conduct structured walkthroughs with peer engineering groups to simulate edge-case failures, refine procedural ambiguities, and validate abort criteria prior to physical execution.
   - Deliverable: Peer Review Audit Log and Revised Migration Plan (mapped to ISO control A.5.37).

---

## Phase 3 Reference Standard: Rack Elevation Architecture

The submitted elevation diagram must meet production engineering standards:

```
+-------------------------------------------------------+ U42
|  [Active Equipment] Patch Panel + Top-of-Rack Switch  | U40
+-------------------------------------------------------+ U39
|  [Reserved] Reserved for Future Switch / Expansion    | U38
+-------------------------------------------------------+ U37
|  [Active Equipment] Application Server Node 01        |
|  [Active Equipment] Application Server Node 02        |
|  [Active Equipment] Application Server Node 03        |
|  [Active Equipment] Application Server Node 04        | U30
+-------------------------------------------------------+ U29
|  [Mandatory] 2U Blanking Panel (Prevents Recirculation)| U28
+-------------------------------------------------------+ U27
|  [Active Equipment] Core Database / Clustered Storage | U20
+-------------------------------------------------------+ U19
|  [Mandatory] 6U Blanking Panel                        | U14
+-------------------------------------------------------+ U13
|  [Active Equipment] High-Density Storage Array        | U06
+-------------------------------------------------------+ U05
|  [Active Equipment] Uninterruptible Power Supply (UPS)| U01
+-------------------------------------------------------+
```

### Key Rack Design Rules

1. Centre of gravity: Heaviest components (UPS batteries, high-density disk arrays) must be installed at the lowest rack units (U1–U13) to prevent rack tipping.
2. Thermal sealing: All unpopulated U space must be capped with blanking panels; unsealed gaps short-circuit hot exhaust into cold supply channels.
3. Power redundancy: Redundant power supply units (PSU A and PSU B) must connect to independent Power Distribution Units (PDU A and PDU B) on separate electrical phases.
4. Circuit utilization: Maximum continuous electrical load per branch circuit / PDU phase must not exceed 80% of rated capacity.

---

## Lab Deliverables, Team Roles, and Safety Protocols

### Deliverables and Grading Criteria (Total: 10 Marks)

- Group Size: 3 to 4 students per team (15–20 groups total).
- Due Date: Start of Week 2 session.

| Assessment Component | Allocated Marks | Success Criteria |
| :--- | :--- | :--- |
| Inventory Completeness | 3 Marks | 100% audit of hardware serials, exact U coordinates, component owners, and associated production services. |
| Dependency Map Quality | 2 Marks | Explicit mapping of service-level failure cascades, control paths, and validated criticality tiers. |
| MOP Clarity & Rigour | 2 Marks | Granular, step-by-step procedure readable by outside engineers, including realistic durations and verification checks. |
| Rollback Feasibility | 2 Marks | Realistic abort criteria, unambiguous triggers, and defined Maximum Tolerable Downtime (MTD) to return to baseline. |
| ISO 27001 Alignment | 1 Mark | Accurate, justifiable mapping of operational activities to ISO/IEC 27001:2022 Annex A controls. |

### Operational Team Roles

Roles rotate weekly and mirror incident response command structures introduced in Week 15:

- Change Owner: Holds overall accountability for the change procedure; possesses sole authority to declare an abort and initiate rollback.
- Inventory Lead: Responsible for data accuracy and validation of every entry across physical asset registers and cable matrices.
- Safety Officer: Responsible for physical safety compliance, environmental monitoring, and data centre access rules.
- Scribe: Maintains timestamped logs of all actions, observations, environmental metrics, and discovered discrepancies.

### Mandatory Data Centre Safety Protocols

- No Disconnections: Strictly zero disconnections, unpluggings, or power manipulations permitted during observational survey phases.
- Authorized Access Only: Entry into the data centre facility requires continuous presence of course instructors or certified facility staff; badge sign-in/sign-out mandatory.
- Information Security (Control A.7.4): Strictly forbidden to photograph asset tags, network cabling labels, network topology schematics, or management consoles for dissemination outside the secure course portal.
- Hazard Reporting: Any anomalous sensory condition (electrical burning odors, unusual acoustic vibration, crushed cabling) must be reported immediately to facility engineers; do not attempt unilateral physical remediation.

---

## Preparation and Next Week Assignments

Theme for Week 2: SLI / SLO / SLA and Error Budgets (Quantifying Reliability).

### Individual Preparation
- Reading: Google SRE Book, Chapter 4 ("Service Level Objectives") — available at sre.google/books.
- Assessment: Complete Pre-Class Quiz 1 on the university LMS.
- Exercise: Identify and document one software service used daily for analysis in Assignment 1.

### Group Deliverables
- Finalize the Asset Inventory Sheet and Dependency Analysis Map.
- Commit all artifacts, along with the physical data centre access sign-in log, into the team Git repository.
- Compile unresolved architectural questions for review in the next session.

### Environment Readiness
- Deploy and verify the course sample distributed application using Docker Compose.
- Establish and record baseline end-to-end response-time latencies.

### Opening Challenge for Next Session
> If you had to tell the university president in a single number whether the registration system is good enough, what number would you use?

---

## References and Standards

### Core Texts
- Beyer, B., Jones, C., Petoff, J., & Murphy, N. R. (2016). *Site Reliability Engineering: How Google Runs Production Systems*. O'Reilly Media. (Chapters 1–3, 5). Available free at `sre.google/books`.
- Beyer, B. et al. (2018). *The Site Reliability Workbook: Practical Ways to Implement SRE*. O'Reilly Media. (Chapters 1–2).

### Case Studies and Industry Reports
- Amazon Web Services (2025). *Summary of the Amazon DynamoDB Service Disruption in Northern Virginia (us-east-1)*, October 2025.
- ThousandEyes (2025). *AWS Outage Analysis: October 20, 2025*.
- IncidentHub (2026). *H1 2026 Cloud and SaaS Reliability Report* (July 2026).
- Forrester Research (2026). *Predictions 2026: Cloud Computing*.
- InfoQ (2026). *Coinbase Postmortem on a Localized AWS Failure* (June 2026).
- DORA (2025). *State of AI-assisted Software Development*. `dora.dev`.

### International Standards
- ISO/IEC 27001:2022: Information security, cybersecurity and privacy protection — Information security management systems — Requirements (Annex A controls).
- ISO/IEC 27002:2022: Information security, cybersecurity and privacy protection — Information security controls.
- ISO/IEC 22237 Series: Information technology — Data centre facilities and infrastructures.
- ISO/IEC 30134-2: Information technology — Data centres — Key performance indicators — Part 2: Power Usage Effectiveness (PUE).

---

## Summary in Three Sentences

1. Reliability is a product attribute you design, measure, and pay for; it does not happen on its own.
2. The goal is not a system that never fails, but one that fails predictably and recovers before users give up.
3. Repetitive manual work is a debt you pay every month; at least half the team's time must go into engineering it away.
