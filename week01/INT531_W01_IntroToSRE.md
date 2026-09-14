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

## Course Structure, Teaching Philosophy, and Evaluation

### Lecturer Commentary / Practical Context: Pedagogical Approach vs. Prerequisite Courses

1. Distinction from Prerequisite Networking Courses:
   - In compulsory introductory networking courses, pedagogy is structured in sequential, guided steps (step 1, step 2, step 3).
   - In INT 403 / INT 531 SRE, the format transitions entirely to real-world engineering and self-directed problem-solving.
   - SRE is broad and multidisciplinary, encompassing systems, data centre physical facilities, networks, software architecture, release engineering, and business operations. Students must investigate, read documentation, and resolve ambiguous issues independently.

2. Assessment Breakdown:
   - Three Modular Evaluation Slots: Conducted approximately every 5 weeks (15% per slot = 45% total).
   - Practical Lab Examination: 15%.
   - Continuous Assessment (Assignments, Project Setup, Class Activities): 40%.

3. Oral Examination Protocol (Video Defense):
   - Formal evaluations are NOT written tests and do NOT permit copying/pasting from AI prompts or external materials.
   - Evaluation format: Students sit in front of a camera with screen recording enabled. Technical questions and operational scenarios appear on-screen sequentially.
   - Students must articulate, reason through, and verbally explain the concepts and system architectures directly into the camera in real time.
   - Audio recordings are transcribed and evaluated (using automated transcription and instructor/AI grading). Incoherent answers, memorized buzzwords without underlying logic, or evasive responses receive zero credit.
   - Rationale: Real-world engineering requires clear verbal communication during live production incidents, postmortems, and stakeholder briefings.

---

## Industry Job Market and Hardware Economics in 2026

### Lecturer Commentary / Practical Context: The 2026 Employment and Infrastructure Landscape

1. Structural Shifts in IT Employment:
   - Historical baseline: Two years prior (before widespread generative AI deployment), senior IT graduates enjoyed a 90% to 99% employment rate prior to graduation.
   - 2026 baseline: Approximately 40% of recent graduates are currently unemployed.
   - AI impact on junior developers: Enterprises have sharply reduced hiring for standard junior programmers who only write basic boilerplate or prompt AI chat interfaces. AI has increased delivery throughput, meaning companies require fewer entry-level coders.
   - AI impact on UX/UI designers: Entry-level UX/UI positions have diminished significantly. Business Analysts (BAs) and product engineers use generative design systems to rapidly produce customer-facing mockups and prototypes directly from business requirements. UX/UI practitioners must pivot toward deep business analysis and technical product ownership.
   - How students must adapt: Strong foundational systems knowledge (computer architecture, networking, distributed systems, error budgets, telemetry) combined with business domain understanding is the single most defensible career profile.

2. Hardware Market Economics and Supply Chain Volatility:
   - GPU / AI compute distortion: Semiconductor wafer manufacturing capacity is overwhelmingly directed toward high-margin AI GPUs and specialized accelerators rather than consumer/server RAM and enterprise SSDs.
   - Price inflation: Enterprise M.2 NVMe SSDs that previously cost approximately 2,000 THB escalated to 5,000 THB and reached 8,000 THB within months.
   - Procurement reality: Hardware vendors no longer guarantee quotation prices for the standard 30-to-90-day institutional purchase cycle. Price validity has shrunk to as little as 7 days, with international memory chip orders priced only upon physical collection.
   - University notebook leasing constraint: Student laptop fleets leased under fixed 3-year contracts (~800 THB/month per machine) face procurement deadlocks because market replacement costs have exceeded budget ceilings by over 60%, making hardware preservation mandatory.

3. The Data Centre Boom vs. Actual Employment Reality in Thailand:
   - Massive hyperscaler and multinational investments in Thailand (e.g., Eastern Economic Corridor / Chonburi hyperscale facilities, urban carrier-neutral facilities like Telehouse Rama 9, and the 4-billion THB land development at Makkasan).
   - Misconception: Data centres do NOT create thousands of continuous manual jobs like manufacturing assembly plants.
   - Operational reality: Physical construction and initial equipment deployment require short-term contract labor (often executed by foreign turnkey engineering firms). Once operational, modern hyperscale facilities are managed by minimal staff and extensive software automation.
   - Industry benchmark: Meta manages hundreds of thousands of network switches worldwide with an engineering team of approximately three dedicated switch automation engineers. Operational staff are only needed for physical component swapping.

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

### Lecturer Commentary / Practical Context: Anatomy of Cascading Failures and Recovery Delays

1. Why Did Recovery Require 15 Hours When the Bug Was Fixed in Under 3 Hours?
   - The root defect (overwritten DynamoDB DNS endpoints) was diagnosed and manually rectified by 02:25.
   - However, DNS is a globally distributed, cached protocol. Inconsistent and corrupted DNS records had propagated across recursive resolvers and caches worldwide.
   - Client applications and intermediate caches continued serving stale or negative responses according to Time-to-Live (TTL) cycles.
   - Furthermore, when DynamoDB endpoints reappeared, thousands of disconnected upstream services attempted simultaneous reconnection, causing massive thundering herd problems, connection pool exhaustion, and message queue backups that required over 12 additional hours to drain safely.

2. Local Educational Parallel: Domain Migration at SIT KMUTT:
   - When the SIT faculty migrated its learning management system from `elearning.sit.kmutt.ac.th` to `newlearning.sit.kmutt.ac.th`, the authoritative internal DNS records were updated in minutes.
   - However, external consumer ISPs across Thailand (True, AIS, 3BB / Triple T Broadband) updated their recursive resolver caches at differing intervals. Some providers took weeks to propagate the new domain, preventing students from accessing course materials from home unless they explicitly switched their local device resolvers to public DNS (e.g., Google 8.8.8.8).
   - This illustrates the core SRE principle: Fixing the server does not mean the user's service is restored.

3. Control-Plane and Circular Dependencies:
   - AWS engineers attempting to remediate the outage encountered broken internal tooling because internal AWS orchestration, authentication, and monitoring platforms themselves depended on DynamoDB and Route 53 endpoints.
   - When your recovery tools depend on the system that is down, you cannot automate recovery and are forced into slow, high-risk manual interventions.

4. Blameless Culture vs. The Cover-Up Mentality:
   - In traditional legacy IT environments, incident responses frequently involve secrecy, evasive claims ("the server just hung, we rebooted it"), or shifting blame to protect individuals from termination or salary cuts.
   - In mature SRE practice, transparency is mandatory. AWS released an exhaustive, public post-event summary detailing the exact race condition, the failure of automated rollbacks, and concrete mitigation steps.
   - Blameless postmortems operate on the assumption that engineers make decisions in good faith based on available data. If an engineer triggers a bug, the systemic design, testing harness, and safety boundaries failed, not the person.
   - Concealing root causes prevents organizational learning and guarantees the recurrence of catastrophic downtime.

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

### Lecturer Commentary / Practical Context: SRE Competency and Shared Alignment

1. SREs Must Be Capable Software Engineers:
   - An effective SRE possesses software engineering competencies on par with core product developers. An SRE can write production code, understand distributed data structures, and contribute directly to the application codebase.
   - The fundamental difference is domain focus: SREs apply engineering discipline to reliability, operability, scalability, and automated fault recovery.

2. Eliminating Adversarial Silos:
   - Traditional Ops vs. Dev dynamics:
     * Dev goal: Ship features rapidly; rewarded for deployment volume.
     * Ops goal: Keep servers online; rewarded for zero changes, leading to gatekeeping and conflict.
     * When failures occur, Ops blames bad code; Dev blames server misconfiguration ("it ran fine on localhost, the code hasn't changed in months, so it must be your infrastructure").
   - SRE eliminates this conflict by uniting both groups under shared ownership of the **End-User Experience**.

3. The Metric That Matters: End-User Success:
   - Server metrics alone (CPU load, memory consumption, interface packet rates) do NOT determine service health.
   - Example: A university registration system may report 0% CPU utilization and 100% web server uptime, yet thousands of students cannot register because the payment API integration is returning 504 gateway timeouts. From the user's standpoint, the service is 100% down.
   - SRE forces engineers to define and measure health from the boundary where the user interacts with the system.

4. Preventing On-Call Burnout:
   - Historical context: System administrators traditionally carried on-call pagers 24/7 without structured limits, waking up at 03:00 AM or 05:00 AM in constant paranoia over unmonitored failures.
   - SRE establishes explicit operational limits: alert thresholds must be actionable, paging must only trigger for genuine user-impacting emergencies, and on-call rotations are strictly capped. If a system consumes too much operational time, production ownership is pushed back to the product developers until reliability improves.

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

*Conceptual Note:* "Class SRE implements DevOps" — SRE provides concrete, programmatic, and measurable mechanisms to implement the cultural philosophy of DevOps. DevOps describes *what* needs to be achieved culturally; SRE provides the programmatic mechanisms (*how*) to execute and measure it.

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

### Lecturer Commentary / Practical Context: Real-World Nuances of Availability Metrics

1. Time-of-Day and Contextual Impact:
   - A raw statistical percentage does not reflect business damage:
     * 43.2 minutes of total downtime occurring at 03:00 AM on a Sunday morning is generally invisible and acceptable for university administrative services.
     * Conversely, 3 minutes of downtime at 09:00 AM on the opening morning of course registration causes thousands of students to lose course slots and triggers widespread public criticism.
   - SRE SLOs must be time-aware and context-sensitive rather than simple 30-day flat averages.

2. Physical Datacenter Siting and Carrier Interconnections:
   - Why do facilities like Telehouse Rama 9 or Makkasan build on land costing over 4 billion THB in central Bangkok instead of cheap rural land?
   - Telecom Carrier Density: Central Bangkok hosts all domestic telecommunications carriers and internet exchange nodes (True, AIS, NT). Cross-connects between operators can be provisioned with minimal latency and high resilience without running long-haul terrestrial dark fiber.
   - Power Grid Stability: In Thailand, the Metropolitan Electricity Authority (MEA) business district grid in central Bangkok is strictly protected from the heavy load swings and voltage dips typical of industrial manufacturing estates in outer provinces.

3. The Fallacy of 100% Target:
   - Chasing 100% availability requires multiplying every component across hardware, dual PDU feeds, redundant UPS strings, multi-carrier BGP links, and distributed multi-region databases.
   - Mathematical serial reliability degradation:
     $$A_{\text{total}} = A_1 \times A_2 \times A_3$$
     If a user flow depends sequentially on three services, each running at 99.9% availability:
     $$0.999 \times 0.999 \times 0.999 \approx 0.997003 \text{ (99.7\%)}$$
     Allowed monthly downtime triples from 43.2 minutes to over 2 hours and 9 minutes.
   - SREs design graceful degradation (e.g., caching, static fallback pages, asynchronous queueing) so a failure in one dependent component does not take down the entire user transaction.

4. The Error Budget Concept:
   - Error Budget is defined as:
     $$\text{Error Budget} = 100\% - \text{SLO}$$
   - For a 99.9% SLO, the error budget is 0.1% allowed failure.
   - An error budget gives development teams an explicit quota to deploy new features and take calculated architectural risks. If the budget is exhausted, releases are halted, and engineering capacity shifts entirely to reliability hardening.

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

### Lecturer Commentary / Practical Context: AI Tooling in Toil Elimination

- Modern generative AI and scripting platforms can eliminate operational drudgery:
  * Automating Ansible playbooks, writing parsing scripts for serial numbers, and synthesizing SNMP/PUE facility metrics into automated reports.
  * SREs leverage AI to synthesize runbooks and generate initial automation logic, but engineers must validate the safety guards, rollback criteria, and execution boundaries.

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

### Lecturer Commentary / Practical Context: Enterprise AI Dependency Vulnerabilities

1. Third-Party LLM Outage Cascades:
   - If an enterprise builds customer service or automated triage entirely dependent on OpenAI, Anthropic, or Google APIs, an outage at the third-party provider completely paralyzes the internal system.
   - Architectural mitigation: Design multi-model fallback strategies (e.g., primary frontier model falling back to lightweight local/hosted LLMs or deterministic heuristic rules) accompanied by aggressive client timeouts (e.g., 2.5 seconds) and circuit breakers.

2. On-Premises Faculty AI Hardware Constraints:
   - SIT KMUTT maintains an on-premises AI server environment (accessible through faculty advisors via internal services).
   - Real-world constraints: Legacy compute servers retrofitted with modern GPU cards face power delivery and thermal throttling challenges. In recent trials, GPU units suffered hardware failure before formal commissioning. Enterprise hardware requires continuous warranty tracking, spares management, and thermal monitoring.

---

## The Emerging Role: Forward Deployed Engineer (FDE)

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

### Lecturer Commentary / Practical Context: Bridging Engineering and Business Acumen

1. The Critical Missing Skill in New Graduates:
   - Industry alumni frequently report that university candidates possess reasonable baseline technical skills but completely lack business comprehension.
   - Example scenario: When asked in an interview, "Why did you select this tech stack or design pattern?", candidates often answer, "Because the instructor assigned it."
   - When asked how a shopping cart project handles checkout and payment gateway integration, candidates often fail to consider transaction boundaries, user conversion, or payment fallback paths.
   - Real-world engineering requires understanding business value: What is the monetary cost of downtime? How does the transaction close? How do we minimize user drop-off?

2. What Differentiates an FDE:
   - An FDE operates at the intersection of business strategy, software engineering, and production SRE.
   - They work directly alongside enterprise client users, writing custom glue code, mapping internal schemas, and deploying solutions onto client infrastructure, while ensuring systems meet enterprise SLOs.

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

### Lecturer Commentary / Practical Context: Data Centre Facilities and Lab Logistics

1. The Reality of the SIT Data Centre Space (LX Building, 8th Floor):
   - The faculty previously utilized legacy open racks that had accumulated rust, dust, and outdated cabling.
   - The university's central Computer Center (SIT Data Centre, 8th floor LX Building) recently modernized its space into modular hot/cold aisle containment corridors.
   - SIT secured access to 4 dedicated containment racks in this facility, with 1 rack specifically allocated for INT 403 / INT 531 coursework.
   - Physical infrastructure benefits: Shared access to high-efficiency industrial chillers, automated fire suppression systems (FM-200 / Inergen rather than makeshift ceiling extinguishers), high-capacity centralized UPS, and diesel generators.

2. Hardware Allocation and Team Sizing:
   - Target machine count: 20 physical server nodes.
   - Group size rule: Strictly 2 to 3 students per group (never 4 or 5).
   - Rationale: In teams larger than 3, only one student actively configures the hardware while others remain passive observers. Hands-on exposure is mandatory for every student.
   - Hardware breakdown: 8 groups will receive blade server nodes from a decommissioned enterprise blade chassis; remaining groups will receive dedicated 1U/2U server chassis.

3. Physical Safety and Equipment Handling:
   - Heavy chassis hazard: Fully loaded blade chassis or disk arrays weigh several hundred kilograms. Lifting an assembled chassis will cause severe spinal injury.
   - Procedure: Equipment must be completely disassembled prior to transport: remove all power supplies, blade cards, storage drives, and fan trays. Even an empty bare chassis requires 5 to 6 people to lift safely.
   - Center of gravity rule: Heaviest equipment (UPS batteries, dense disk enclosures) must always be installed in the lowest rack units (U1–U13) to prevent rack tipping.

4. Thermal Dynamics and Containment Discipline:
   - Containment creates a sealed box isolating supply air (fed from raised floor perforated tiles) from hot exhaust air.
   - Leaving containment doors open or failing to install blanking panels causes cold air loss, triggers thermal imbalance, forces chillers to overwork, and trips facility environmental alarms.
   - ISO/IEC 27001 controls govern facility access: biometric facial scanning, entry/exit logging (A.7.4), and zero unauthorized photography of asset tags, cabling schemes, or internal terminals.

5. Classroom-to-Datacenter Layer 2 Network Link:
   - The lab classroom currently possesses dedicated patch cabling connected directly to the 8th floor data centre rack switch on the same Layer 2 broadcast domain.
   - Plugging into the wall outlet provides direct Layer 2 connectivity without routing hops, enabling immediate discovery and out-of-band management of laboratory hardware before formal network segregation policies are applied.

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

- Group Size: 2 to 3 students per team (strictly enforced; max 20 groups total).
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
