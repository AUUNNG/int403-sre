# INT531 Site Reliability Engineering

## Week 2: SLI / SLO / SLA and Error Budgets
**Putting a number on "good enough"**

- Institution: School of Information Technology, King Mongkut's University of Technology Thonburi
- Course Structure: Lecture 2 h + Field lab 1.5 h
- Content Revision: 2026

---

## 1. Agenda and Overview

Lecture 1.5 h + Field session briefing 1.5 h

1. **From an open question to a number**: Why "the system feels stable" cannot support any decision.
2. **SLI / SLO / SLA**: Three terms people swap around, and what breaks when they do.
3. **Choosing a good SLI**: An SLI menu by service type, and the trap of measuring the wrong side.
4. **Error budgets**: The budget, the burn rate, and the policy for when it runs out.
5. **Lab 2 - two field sessions**: Walk the containment room, then the decommission and move day.
6. **Room access and asset handback**: The procedure under ISO/IEC 27001 and related standards.

---

## 2. Session Learning Outcomes

| Outcome Code | Description | Course Learning Outcome (CLO) |
| :--- | :--- | :--- |
| SLO 2.1 | Tell SLI, SLO, and SLA apart and give an example of each | CLO2 |
| SLO 2.2 | Choose an SLI that suits the service type, and explain why it must be measured from the user's side | CLO2 |
| SLO 2.3 | Compute an error budget from an SLO and convert it into allowable downtime | CLO2 |
| SLO 2.4 | Write an error budget policy that says what happens as the budget runs down | CLO2, CLO7 |
| SLO 2.5 | Explain why averages mislead and why percentiles are used instead | CLO2 |
| SLO 2.6 | Follow the controlled-area access and asset handback procedures correctly | CLO3, CLO7 |

---

## 3. From an Open Question to a Usable Number

### The Guiding Question
> "If you had one number to say whether the registration system is good enough, what would it be?"

### Answers That Sound Fine But Decide Nothing

- **"99.9% uptime"**
  - Problem: Uptime of what, measured where? If the web server returns HTTP 200 but the page never actually renders for the student, does that still count as "up"?
- **"CPU averages 40%"**
  - Problem: This is a metric about hardware utilization, not user experience. An idle CPU can easily coexist with complete service failure (e.g., deadlocked threads, blocked database connections, authentication service crash).
- **"Nobody has complained"**
  - Problem: Does silence mean no problem exists, or does it mean users gave up and walked away? Operating in the dark leaves engineering unable to distinguish satisfaction from abandonment.

### An Answer You Can Act On
> "Over the last 30 days, 99.2% of registration submissions succeeded within 2 seconds - below the 99.5% target we set."

This statement provides complete operational clarity:
- **What was counted**: Registration submissions.
- **From whose side**: User-facing request path.
- **Over what window**: Rolling 30 days.
- **Against what target**: Compared directly against the agreed 99.5% objective.

---

## 4. SLI, SLO, SLA: Distinctions, Ownership, and Boundaries

These three terms must never be used interchangeably. Each represents a distinct tier of service governance with a different owner, audience, and consequence.

```
+-------------------------------------------------------------------+
|                        SLI (Indicator)                            |
|  What you measure: Ratio taken from the user's side               |
|  Formula: (Successful requests / All valid requests)              |
|  Owner: Whoever instruments the service                           |
+---------------------------------+---------------------------------+
                                  |
                                  v
+-------------------------------------------------------------------+
|                        SLO (Objective)                            |
|  The internal target committed by engineering                     |
|  Example: "99.9% over 30 days"                                    |
|  Owner: The engineering team                                      |
+---------------------------------+---------------------------------+
                                  |
                                  | (SLO must be stricter than SLA)
                                  v
+-------------------------------------------------------------------+
|                        SLA (Agreement)                            |
|  The customer contract: Promise with financial/credit penalty    |
|  Always looser than the internal SLO                              |
|  Owner: Legal and the business                                    |
+-------------------------------------------------------------------+
```

### Summary Comparison Table

| Metric Tier | Definition | Core Meaning | Owner | Audience | Consequence of Failure |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **SLI** | Service Level Indicator | What you actually measure | Instrumentation / SRE engineers | Engineers | Triggers internal metric alerts |
| **SLO** | Service Level Objective | Internal reliability target | Engineering team | Engineering and Product Owners | Halts deployments, redirects effort to reliability |
| **SLA** | Service Level Agreement | Legally binding contract | Business and Legal | External customers / Executives | Financial penalties, rebates, breach of contract |

### Critical Governance Rules
- **Error Budget Definition**: $\text{Error Budget} = 100\% - \text{SLO}$.
  - At an SLO of $99.9\%$ over a 30-day window, the team is allowed $0.1\%$ failure, which equals exactly **43.2 minutes** of allowable downtime.
- **Common Pitfall**: Setting the SLO equal to the SLA. If internal SLO = external SLA, the first time the internal target is missed, the organization is immediately in breach of contract with monetary and legal consequences. The SLO must always be stricter than the SLA to provide a safety margin.

---

## 5. Anatomy of an SLI and the Core Equation

Every usable SLI is a ratio of events. If a metric cannot be stated as a fraction, it is not yet defined.

### General Formula

$$\text{SLI} = \frac{\text{Good Events}}{\text{Valid Events}} \times 100\%$$

Where:
- **Good Events**: Total requests that met all defined success criteria (status code, latency, payload correctness).
- **Valid Events**: All incoming requests that should legitimately have been served.

### Worked Example: Registration Submissions (30-Day Window)

| Line Item | Count | Status / Role in Calculation |
| :--- | :--- | :--- |
| Total submissions received | 205,140 | Raw total at perimeter |
| Health checks and synthetic probes | - 5,140 | **Excluded** from denominator |
| **Valid events (Denominator)** | **200,000** | Net real user attempts |
| Returned HTTP 2xx within 2 seconds | **198,412** | **Good events (Numerator)** |
| Failed submissions ($200,000 - 198,412$) | 1,588 | Unsuccessful events |

$$\text{SLI} = \frac{198,412}{200,000} \times 100\% = 99.206\%$$

### The Exclusion Principle
Excluding events from the denominator is an explicit engineering decision, not an implementation detail. Every exclusion must be explicitly documented and periodically reviewed. Unrecorded exclusions are where SLIs quietly become dishonest.

---

## 6. From Specification to Implementation

Every SLO requires two distinct layers. Without separating specification from implementation, two different engineers will measure two completely different numbers.

### Specification vs. Implementation Framework

| Layer | What It Contains | Registration System Example |
| :--- | :--- | :--- |
| **Specification** | The plain-language meaning with zero tooling or infrastructure detail | The proportion of registration submissions the system serves successfully within an acceptable time |
| **Implementation** | The concrete mathematical formula, telemetry source, filters, and thresholds | Measured at load balancer: requests with HTTP status < 500 and response time $\le 2\text{ s}$, divided by all requests to path `/register` |
| **Exclusions** | Events excluded from the denominator, each with an explicit documented justification | Health check probes, internal synthetic monitoring pings, and client-aborted connections (cancelled by user before timeout) |

### Core Architectural Principles
1. **Why Two Layers Exist**:
   - The *specification* is what product managers, business leaders, and users discuss and agree upon.
   - The *implementation* is what software and reliability engineers instrument, test, and alert against.
   - Without both layers, debates regarding what constitutes "success" never end.
2. **Measurement Location Dictates Truth**:
   - Measuring inside the application runtime misses edge web server and load balancer crashes.
   - Measuring at the load balancer misses authoritative DNS lookup failures and external network transit drops.
   - The closer measurement is taken to the end user, the closer it reflects reality.
3. **Explicit Exclusion Documentation**:
   - Every excluded request type artificially improves the resulting SLI number.
   - All exclusions must have written justifications and undergo regular audits rather than being added quietly when metrics look poor.

---

## 7. Choosing an SLI by Service Type

Never measure what is simply easy to extract from a vendor tool. Measure what directly impacts the user's perception of service quality.

### SLI Menu by Architecture

| Service Type | What the User Cares About | Standard SLIs to Use | Campus System Example |
| :--- | :--- | :--- | :--- |
| **Request / Response** | "It works when I click, and returns results fast enough." | Availability, Latency, Correctness | Student Registration, Learning Management System (LMS), Faculty APIs |
| **Batch Pipeline** | "The data arrives completely, without loss, and on time." | Freshness, Coverage, Correctness | Grade calculation rollups, Daily student data synchronization |
| **Storage / Object Store** | "What I wrote into storage can always be retrieved accurately." | Durability, Availability, Read/Write Latency | Shared campus network file storage, System backup repositories |

### Three Traps That Produce Misleadingly Good SLIs

1. **Measuring Only at the Server**:
   - The backend service reports HTTP 200 for every incoming connection.
   - If the intermediate Content Delivery Network (CDN) or ingress load balancer misroutes traffic or fails TLS termination, the user receives an error screen while the server SLI reports 100% health.
2. **Counting Only Requests That Successfully Arrive**:
   - During severe network blackouts, packet storms, or connection pool exhaustion, user requests fail at the edge before reaching application instrumentation.
   - Because only surviving requests reach the counter, the recorded success rate paradoxically spikes during major outages.
3. **Using Arithmetic Averages Instead of Percentiles**:
   - A single average metric completely masks severe tail latency suffered by the most active users.

---

## 8. Why Averages Lie and the Mathematics of Percentiles

### Illustrative Data: Registration System Opening Day

- Measured Average Latency (Mean): **380 ms** (passes internal targets comfortably)
- Latency Distribution by Percentile:

| Metric | Latency Value | User Impact Analysis |
| :--- | :--- | :--- |
| **Average (Mean)** | 380.0 ms | Appears healthy; managers assume performance is exceptional |
| **p50 (Median)** | 210.0 ms | 50% of requests complete in 210 ms or faster |
| **p90** | 890.0 ms | 10% of users wait longer than 890 ms |
| **p99** | 3,100.0 ms (3.1 s) | 1 out of every 100 users waits over 3 seconds |
| **p99.9** | 8,200.0 ms (8.2 s) | 1 out of every 1,000 users waits over 8.2 seconds |

### Tail Latency Reality Check
- With 200,000 total requests in a day:
  - **p99 degradation**: $1\% \times 200,000 = 2,000$ users experience agonizingly slow submissions exceeding 3 seconds.
  - **p99.9 degradation**: $0.1\% \times 200,000 = 200$ users wait over 8 seconds.
  - These 200 to 2,000 frustrated users are the individuals who flood helpdesks, submit support tickets, and frantically click "refresh" or "retry", compounding server load into a cascading outage.

**Rule of Thumb**: Always define latency SLOs as percentiles (e.g., p95, p99, p99.9), and select the percentile tier based on total transaction volume and the absolute number of real human beings represented by the remaining tail.

---

## 9. Computing a Percentile Step-by-Step

### Step-by-Step Calculation Procedure
Given an ordered sample of 20 latency observations (in milliseconds):
$$[95, 110, 128, 141, 155, 168, 180, 196, 210, \mathbf{232}, 258, 290, 340, 420, 560, 780, 1120, \mathbf{1850}, \mathbf{3400}, 8200]$$

1. **Order the raw sample data** from lowest to highest.
2. **Determine rank index**:
   - 50th percentile ($p50$): 10th value $\rightarrow \mathbf{232\text{ ms}}$
   - 90th percentile ($p90$): 18th value $\rightarrow \mathbf{1,850\text{ ms}}$
   - 95th percentile ($p95$): 19th value $\rightarrow \mathbf{3,400\text{ ms}}$
   - Maximum ($p100$): 20th value $\rightarrow 8,200\text{ ms}$

### Three Fundamental Rules of Percentiles

1. **Statistical Sample Floor**:
   - To compute a statistically sound $p99$, a minimum of **100 samples** is required within the measurement window.
   - To compute $p99.9$, at least **1,000 samples** are required. Calculating high percentiles with insufficient traffic produces meaningless figures.
2. **Scale Percentile Tier to User Base**:
   - For an application with 20,000 active sessions, a $p99$ target leaves 200 users suffering degraded performance. High-volume systems require $p99.9$ or $p99.99$ targets.
3. **Use Histograms in Production Monitoring**:
   - Storing all raw execution times in distributed production systems is prohibitive in memory and storage. Production tools (e.g., Prometheus) use histogram buckets to estimate percentile distributions.

### The Cardinal Prohibition of Percentiles
> **You cannot average percentiles.**
> The arithmetic mean of Server A's $p99$ and Server B's $p99$ is mathematically NOT the $p99$ of the combined cluster. To find cluster-wide percentiles, one must aggregate underlying histogram buckets or recompute from raw samples.

---

## 10. Composite Availability: Series vs. Parallel Dependencies

A system's maximum achievable reliability is strictly constrained by the architecture and availability of its upstream and downstream dependencies.

```
1. Series Architecture (Every hop must succeed):
[ Web Tier (99.9%) ] ---> [ API Service (99.9%) ] ---> [ Database (99.9%) ]
Result: Availability drops to 99.7% (2 hours 10 minutes downtime / 30 days)

2. Parallel Architecture (Redundancy - one survivor is enough):
                      +---> [ Node A1 (99%) ] ---+
[ Load Balancer ] --->|                          |---> Output
                      +---> [ Node A2 (99%) ] ---+
Result: Availability increases to 99.99% (4.3 minutes downtime / 30 days)
```

### Series Availability Mathematics
In a linear dependency chain where every component must function for the request to succeed:

$$A_{\text{total}} = \prod_{i=1}^{n} A_i = A_1 \times A_2 \times A_3 \times \dots \times A_n$$

- For three chained systems each offering $99.9\%$ ($0.999$):
  $$A_{\text{total}} = 0.999 \times 0.999 \times 0.999 = 0.997002999 \approx 99.7\%$$
- **Operational Reality**: Chaining three $99.9\%$ components yields worse availability ($99.7\% \approx 2\text{ h } 10\text{ min}$ downtime per 30 days) than any individual service in the chain.

### Parallel (Redundant) Availability Mathematics
When identical redundant components operate in parallel and only one component needs to survive:

$$A_{\text{total}} = 1 - \prod_{i=1}^{n} (1 - A_i) = 1 - (1 - A_1) \times (1 - A_2)$$

- For two redundant nodes each with $99\%$ availability ($A = 0.99$, unreliability $1 - A = 0.01$):
  $$A_{\text{total}} = 1 - (0.01 \times 0.01) = 1 - 0.0001 = 0.9999 \ (99.99\%)$$
- **Operational Reality**: Two mediocre $99\%$ nodes in parallel outperform either single node, reducing monthly downtime to **4.3 minutes**.

### Three Core Architecture Rules
1. **Rule One**: Never commit to an SLO higher than the product of your mandatory dependencies. If the backend database provides $99.9\%$, the API cannot promise $99.95\%$ unless it is explicitly architected to serve stale cache or degrade gracefully without the database.
2. **Rule Two**: Every additional component placed in series reduces overall system reliability. Simplification is the most effective reliability engineering technique.
3. **Rule Three**: Redundancy only improves availability if failure modes are strictly independent. If two redundant servers share a common power distribution unit, network switch, or virtualization host, they share a single point of failure and the parallel availability formula does not apply.

---

## 11. Error Budget Arithmetic and Downtime Conversions

An error budget represents the exact amount of unreliability, errors, or downtime a service is permitted to accumulate over a specified rolling window.

> **A budget is time/events you are allowed to spend, not a total catastrophe to avoid at all costs.**

### Allowable Downtime Reference Table

| Target SLO | Allowable Downtime per 30 Days | Allowable Downtime per 7 Days | Allowable Downtime per Day | Target Environment Suitability |
| :--- | :--- | :--- | :--- | :--- |
| **99%** ("two nines") | 7 hours 12 minutes | 1 hour 41 minutes | 14 minutes 24 seconds | Internal tools, non-critical background services |
| **99.5%** | 3 hours 36 minutes | 50 minutes 24 seconds | 7 minutes 12 seconds | General campus services, student portals |
| **99.9%** ("three nines") | 43 minutes 12 seconds | 10 minutes 5 seconds | 1 minute 26 seconds | Production systems with external user interaction |
| **99.95%** | 21 minutes 36 seconds | 5 minutes 2 seconds | 43 seconds | Mission-critical enrollment and registration peaks |

### Operating Principles of Error Budgets
- **Inclusive Scope**: The budget covers all failure categories: unplanned software crashes, bad rollouts, cloud infrastructure outages, and planned maintenance windows alike.
- **Under-spending Risk**: Ending a measurement window with 100% of the error budget intact indicates an overly conservative deployment velocity. The team may be shipping features too slowly, missing market or educational opportunities.
- **Mid-Period Depletion**: Exhausting the error budget mid-month requires immediately stopping new feature deployments to arrest compounding operational risk.

---

## 12. Step-by-Step Error Budget Computation

Worked Example: Registration System with SLO of **99.9%** over a **30-day window** ($200,000$ valid requests).

### Step 1: Calculate Total Time in Window
$$\text{Total Window Minutes} = 30\text{ days} \times 24\text{ hours/day} \times 60\text{ minutes/hour} = 43,200\text{ minutes}$$

### Step 2: Calculate Error Budget as Allowable Downtime
$$\text{Budget}_{\text{time}} = (1 - \text{SLO}) \times \text{Window} = (1 - 0.999) \times 43,200\text{ min} = 0.001 \times 43,200 = \mathbf{43.2\text{ minutes}}$$

### Step 3: Calculate Error Budget as Allowable Failed Requests
$$\text{Budget}_{\text{requests}} = (1 - \text{SLO}) \times \text{Total Valid Requests} = 0.001 \times 200,000 = \mathbf{200\text{ requests}}$$

### Step 4: Quantify Actual Failures Spent
From the SLI calculation in Section 5:
- Total valid requests: $200,000$
- Successful requests: $198,412$
- Actual failed requests:
  $$\text{Failed Requests} = 200,000 - 198,412 = \mathbf{1,588\text{ requests}}$$
- Percentage of budget consumed:
  $$\text{Budget Consumed} = \frac{1,588}{200} \times 100\% = \mathbf{794\%}$$

### Step 5: Determine Operational Position
The team overspent the allowable error budget by a factor of **7.94x**. The error budget is fully exhausted. Under the agreed error budget policy, all non-emergency releases must stop immediately.

---

## 13. Burn Rate: Mathematical Foundations and Alerting

Burn rate measures the acceleration of error budget consumption. Monitoring the current burn rate allows teams to act on catastrophic degradation before the entire budget is drained.

### The Three Core Burn Rate Equations

1. **Burn Rate by Consumption over Time**:
   $$\text{Burn Rate} = \frac{\text{Budget Spent (\%)}}{\text{Time Elapsed (\%)}}$$

2. **Burn Rate by Error Rate**:
   $$\text{Burn Rate} = \frac{\text{Observed Error Rate}}{1 - \text{SLO}}$$

3. **Time to Complete Exhaustion**:
   $$\text{Time to Exhaustion} = \frac{\text{Total Window}}{\text{Burn Rate}}$$

### Worked Example: Mid-Window Outage
Suppose a system is 5 days into a 30-day window, and 60% of the error budget has been spent:
- Time elapsed percentage: $\frac{5}{30} = 16.7\%$
- Budget spent: $60\%$
- Current burn rate:
  $$\text{Burn Rate} = \frac{60\%}{16.7\%} = \mathbf{3.6}$$
- Projected time until total exhaustion:
  $$\text{Time to Exhaustion} = \frac{30\text{ days}}{3.6} = \mathbf{8.3\text{ days}}$$

### Burn Rate Exhaustion and Alerting Matrix

| Burn Rate | Observed Error Rate (for 99.9% SLO) | 100% Budget Depletion Window | Operational Action / Alerting Response |
| :--- | :--- | :--- | :--- |
| **1.0** | $0.10\%$ | 30 days (exact window duration) | Normal baseline consumption. No operational action needed. |
| **2.0** | $0.20\%$ | 15 days | Elevated risk. Monitor trend; document in weekly SRE report. |
| **6.0** | $0.60\%$ | 5 days | Critical leak. File an engineering ticket for resolution during business hours. |
| **14.4** | $1.44\%$ | 2 days (48 hours) | Immediate crisis. Trigger on-call pager immediately to halt runaway burn. |

---

## 14. Error Budget Policy: Rules, Thresholds, and Governance

An error budget policy is a formal operational contract between Development, Operations/SRE, and Product Management. It must be negotiated and signed before incidents occur to prevent finger-pointing during an outage.

### Policy Action Thresholds

```
Remaining Budget
100% +-------------------------------------------------------+
     | Over 50% Left: Ship as normal; run chaos tests        |
 50% +-------------------------------------------------------+
     | 25% - 50% Left: Review high-risk changes; test deeper  |
 25% +-------------------------------------------------------+
     | Under 25% Left: Freeze features; only risk fixes ship |
  0% +-------------------------------------------------------+
     | Budget Exhausted: Total freeze; postmortem required   |
     +-------------------------------------------------------+
```

| Remaining Budget Tier | Permitted Engineering Activities | Mandatory Operational Constraints |
| :--- | :--- | :--- |
| **Over 50% Left** | Standard feature delivery and deployments | Team has room to experiment; ideal phase to conduct game days and chaos experiments |
| **25% - 50% Left** | Standard feature delivery | Scrutinize high-risk pull requests; increase integration and pre-deployment testing |
| **Under 25% Left** | Feature release freeze | Only changes that directly reduce operational risk or enhance reliability may be deployed |
| **Budget Exhausted ($\le 0\%$)** | Complete release halt | All feature deployments stop; 100% of engineering bandwidth shifts to reliability engineering until next window; postmortem is mandatory |

---

## 15. Operational Case Study: One Month of Real Decisions

Walkthrough of a registration system across a single 30-day window ($SLO = 99.9\%$, Total Budget = **43.2 minutes**).

| Day | Incident / Event | Duration Spent | Cumulative Downtime | Remaining Budget (%) | Enforced Policy Action |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Day 3** | Deployment v2.4 introduces regression | 5.0 min | 5.0 min | 88% | Normal operation; proceed with feature work |
| **Day 9** | Primary database failover | 12.0 min | 17.0 min | 61% | Normal operation; proceed with feature work |
| **Day 16** | Scheduled maintenance window | 8.0 min | 25.0 min | 42% | Enter caution phase: review high-risk PRs and tighten pre-deploy testing |
| **Day 22** | Erroneous release; required rollback | 13.0 min | 38.0 min | 12% | Feature freeze enforced: pause new features, deploy only reliability fixes |
| **Day 27** | Core switch network partition | 6.0 min | 44.0 min | -2% (Exhausted) | Hard stop: complete deployment lockdown, engineering shifted to remediation, blameless postmortem initiated |

### Key Takeaway on Maintenance
The 8-minute maintenance window on Day 16 came out of the exact same error budget pool as unplanned outages. Users experiencing service disruption do not distinguish whether downtime was scheduled or accidental.

---

## 16. Field Lab 2: Data Center Decommissioning and Error Budgets

### Rationale: Connecting Physical Infrastructure to SRE Principles
Stripping data center racks represents the single largest planned withdrawal from the annual infrastructure error budget.
1. **Financial and Reliability Cost**: Every minute of physical server downtime directly debits service error budgets.
2. **Scheduling Out of Hours**: Physical strip-outs are performed during low-traffic windows (e.g., Saturday morning) because request-based SLIs suffer the least statistical impact when traffic volume is lowest.
3. **Universal Asset Inventory**: Unregistered hardware is unmanaged hardware. When untracked boxes fail, monitoring cannot identify them, alerts are never sent, and data loss risks remain hidden.
4. **Returning Idle Assets**: Unused servers consume rack units, cooling, and electricity every day while providing zero user value.

---

## 17. Field Session Schedules

All field operations require formal access requests submitted and approved at least five working days in advance.

### Session A: Site Walkthrough
- **Slot**: Week 2 scheduled lab slot (13:00 - 16:00)
- **Location**: New containment room

| Timeline | Activity Description |
| :--- | :--- |
| 13:00 - 13:30 | Access security briefing, identity verification, and sign-in log |
| 13:30 - 14:30 | Physical walk of the containment room layout and rack positions |
| 14:30 - 15:30 | Measurement of free Rack Units (U space), power distribution, and thermal/airflow pathways |
| 15:30 - 16:00 | Group alignment and agreement on the draft target rack layout |

### Session B: Decommission and Move Day
- **Slot**: Week 3 Saturday (09:00 - 16:00, off-peak maintenance window)
- **Location**: Old server room

| Timeline | Activity Description |
| :--- | :--- |
| 09:00 - 09:30 | Sign-in at security desk, escort assignment, comprehensive safety briefing |
| 09:30 - 10:30 | Complete photographic baseline documentation and physical cable labeling |
| 10:30 - 12:00 | Graceful server and appliance shutdown in strict dependency order |
| 12:00 - 13:00 | Scheduled operational break |
| 13:00 - 14:30 | Physical unmounting of equipment; immediate recording of serial numbers |
| 14:30 - 15:30 | Sorting items into Keep, Return, or Dispose paths with physical color-coded tags |
| 15:30 - 16:00 | Formal asset transfer handover to faculty asset officer; sign-out |

---

## 18. Controlled Area Access and ISO/IEC 27001 Controls

Access to university server rooms is governed by ISO/IEC 27001:2022 security controls. Every access step must produce verifiable evidence.

| Step | Action | Operational Detail | Governing ISO/IEC 27001:2022 Control |
| :--- | :--- | :--- | :--- |
| **1** | File the Request | Submit student names, IDs, exact purpose, scheduled date/time, and full tool manifest at least 5 business days in advance | Control A.7.2 (Physical entry) |
| **2** | Obtain Approvals | Course instructor endorses request; facility custodian issues formal approval. Entry is strictly valid only for stated period | Control A.7.2 / A.5.15 (Access control) |
| **3** | Sign In and Escort | Present national/student ID, sign visitor log, remain under physical escort at all times. Unescorted presence is prohibited | Control A.7.2 / Control A.7.4 (Physical monitoring) |
| **4** | Work Within Scope | Execute only tasks explicitly authorized in the request. Facility photography requires explicit case-by-case permission | Control A.7.4 / Control A.5.37 (Documented operating procedures) |
| **5** | Tool Audit and Handover | Re-count all physical tools in and out, deliver updated asset logs to staff, and execute formal sign-out | Control A.7.4 / Control A.5.11 (Return of assets) |

> **Compliance Warning**: Bringing any unauthorized person not listed on the approved access document constitutes an information security control violation and results in forfeiture of group lab marks.

---

## 19. Session A Execution: Walking the Containment Room

### On-Site Measurement Checklist
- Actual available free Rack Units (U space) in each destination rack.
- Placement and status of existing blanking panels.
- Power Distribution Unit (PDU) specifications: electrical voltage/amperage rating, receptacle counts, and connector types (e.g., C13, C19).
- Exact cable run distances from target rack positions to central patch panels.
- Thermal dynamics: hot aisle / cold aisle containment panel locations and airflow direction.
- Facility passage dimensions: physical door and aisle heights/widths to verify transit clearances.

### Mandatory Deliverable Artifacts
- Group-approved draft rack elevation layout.
- Comprehensive cable procurement list with specified lengths, jacket ratings, and connector types.
- Projected electrical power draw per PDU and across individual electrical phases.
- Documented architectural constraints and site discrepancies not present in original blueprints.
- Authorized photographic evidence of site parameters.

---

## 20. Session B Execution: Decommission and Move Day Protocol

Field engineers must execute the strip-out in strict sequential order. Every milestone requires a named, accountable signer.

1. **Pre-Touch Photographic and Backup Verification**:
   - Capture multi-angle photographs of every rack, cable connection, and switch port.
   - Attach indelible labels to both ends of every network, power, and console cable.
   - Confirm that verified, recoverable backups exist for every server before initiating power-down.
2. **Operational Start Declaration**:
   - Broadcast maintenance start notification across agreed stakeholder communication channels.
   - Timestamp the start time and begin tracking active error budget consumption.
3. **Power Down in Dependency Order**:
   - Shut down systems working strictly top-down along the dependency graph.
   - Core infrastructure services (e.g., DNS, LDAP, storage SANs) that other systems rely upon must be powered down last.
4. **Physical Removal and Immediate Inventorying**:
   - Extract hardware one unit at a time.
   - Instantly record serial numbers, original rack U coordinates, and physical condition onto the inventory sheet. Never defer data recording until after the strip-out.
5. **Disposition Sorting and Color Tagging**:
   - Categorize each removed asset into **Keep**, **Return**, or **Dispose** streams.
   - Affix durable color-coded physical tags to each chassis immediately upon extraction.
6. **Formal Asset Handover and Closeout**:
   - Present the comprehensive equipment register to the faculty asset officer for dual signature sign-off.
   - Record the operational completion timestamp and calculate the final error budget consumption.

---

## 21. Building the Asset Register During Strip-Out

The equipment register must be compiled at the exact moment an asset leaves the rack rails, not reconstructed retrospectively from memory.

### Required Fields per Asset Record

| Category | Required Data Fields | Purpose |
| :--- | :--- | :--- |
| **Asset Identity** | Manufacturer, model number, chassis serial number, university asset bar code, MAC address of port 0/eth0 | Unambiguous hardware tracking |
| **Origin and Destination** | Origin rack number, original U position, target disposition stream (Keep / Return / Dispose) | Physical traceability |
| **Operational State** | Services hosted prior to decommissioning, designated system owner, original in-service commissioning date | Service mapping |
| **Storage Media** | Quantity of drives, disk interface (SAS/SATA/NVMe), storage capacity, cryptographic sanitization status | Data leak prevention |
| **Physical Condition** | Chassis damage, missing rail ears/caddies/power supplies, high-resolution visual photograph | Chain of custody audit |
| **Custody Log** | Full name of technician who unmounted unit, name of verifying reviewer, exact timestamp | Accountable verification |

**Rule**: Record one item per row. Never aggregate identical units. Ten identical 1U servers have ten distinct serial numbers and represent ten discrete assets.

---

## 22. Asset Disposition Paths and Data Sanitization

```
                          [ Item Removed from Old Rack ]
                                        |
                                        v
                    +---------------------------------------+
                    | Still in service or planned for new?  |
                    +-------------------+-------------------+
                                        |
                   YES -----------------+----------------- NO
                    |                                      |
                    v                                      v
          +-------------------+                  +-------------------+
          |       KEEP        |                  | Serviceable/Live? |
          | Moves to new rack |                  +---------+---------+
          | Stays in register |                            |
          | New location logged|          YES -------------+------------- NO
          +-------------------+            |                              |
                                           v                              v
                                 +-------------------+          +-------------------+
                                 |      RETURN       |          |      DISPOSE      |
                                 | Surrendered to    |          | Beyond end-of-life|
                                 | asset officer     |          | Destroy / Recycle |
                                 | Signed handback   |          | Requires media    |
                                 | Media sanitized!  |          | sanitization cert |
                                 +-------------------+          +-------------------+
```

### Disposition Stream Definitions
- **KEEP**: Gear transitioning into the new containment room. Remains on active register with updated rack location coordinates (ISO Control A.5.9).
- **RETURN**: Functioning, serviceable equipment no longer required by the lab (e.g., retired storage appliances). Handed back to the institutional equipment officer with dual signatures (ISO Control A.5.11).
- **DISPOSE**: Obsolete, end-of-life, or defective hardware destined for e-waste recycling. Disposal is prohibited until all onboard persistent media are sanitized and certified (ISO Control A.7.14).

### Media Sanitization Mandate
Any component entering the **RETURN** or **DISPOSE** stream that contains storage media (magnetic HDDs, SSDs, NVMe modules, BIOS flash cards, or embedded flash) must undergo certified data sanitization before leaving technical custody. Releasing un-sanitized drives is the primary cause of institutional data leaks.

---

## 23. Handing Back Unused Equipment: The Storage Server Case Study

Step-by-step handback procedure for retiring storage hardware:

1. **Verify Complete Inactivity**:
   - Inspect historical network connection telemetry and access logs.
   - Confirm with application owners that zero active services point to the storage shares.
2. **Preserve Data Under Retention**:
   - If archived files are subject to statutory retention guidelines, migrate records to secure secondary storage and verify checksums prior to drive wiping.
3. **Perform Certified Media Sanitization**:
   - Apply disk sanitization conforming to NIST SP 800-88 Rev. 1 guidelines (e.g., Cryptographic Erase, Multi-pass Overwrite, or physical degaussing/shredding).
   - Generate an official sanitization certificate detailing serial numbers, sanitization method, operator identity, and timestamp.
4. **Update Asset Management System**:
   - Transition asset status from "In-Service" to "Pending Return", recording reason code and approval reference.
5. **Execute Dual-Sign Handover**:
   - Transfer physical custody to the asset officer accompanied by signed handover paperwork and attached sanitization certificates.

---

## 24. Security Standards Compliance Mapping

| Standard Reference | Clause / Control | Mandatory Implementation in SRE Field Work |
| :--- | :--- | :--- |
| **ISO/IEC 27001:2022** | Control A.5.11 | **Return of Assets**: Unused hardware returned with verified signed transfer documentation |
| **ISO/IEC 27001:2022** | Control A.5.15 | **Access Control**: Physical access strictly restricted to personnel named in approved request |
| **ISO/IEC 27001:2022** | Control A.7.1 / A.7.2 | **Physical Security**: Enforced perimeter security; mandatory escort at all times |
| **ISO/IEC 27001:2022** | Control A.7.4 | **Security Monitoring**: Access logs recorded; photography controlled by permit |
| **ISO/IEC 27001:2022** | Control A.7.10 | **Storage Media**: Full custody tracking of persistent media until certified destruction |
| **ISO/IEC 27001:2022** | Control A.7.14 | **Secure Disposal/Re-use**: Mandatory sanitization certificates prior to equipment transfer |
| **ISO/IEC 27001:2022** | Control A.8.32 | **Change Management**: Formal change requests outlining execution windows, risks, and rollbacks |
| **ISO/IEC 22237** | Data Centre Facilities | Environmental, cabling, and rack containment facility specifications |
| **NIST SP 800-88 Rev. 1** | Media Sanitization | Protocols for clear, purge, and destroy cycles on magnetic and solid-state storage |

---

## 25. Move Day Safety and Team Roles

Controlled computer rooms present high physical and electrical hazards. Safety rules admit no exceptions.

### Mandatory Safety Rules
- **Heavy Lifting Limit**: Server chassis exceeding 20 kg require a two-person team lift and mechanical transport trolleys.
- **Strict Disconnection Protocol**: No technician may disconnect a power or network cable until the Change Owner explicitly confirms the system is down and gives the command.
- **Personal Protective Equipment (PPE)**: Closed-toe protective shoes, no loose metal jewelry, long hair tied back securely. Protective work gloves must be worn when working around sharp server sheet metal and cable trays.
- **Emergency Halt Authority**: Any detection of abnormal heat, burning odor, or electrical arcing requires immediate evacuation of the rack aisle. The designated Safety Officer has absolute authority to halt operations instantly without seeking managerial permission.

### Team Roles and Accountabilities

| Role Title | Core Accountabilities |
| :--- | :--- |
| **Change Owner** | Holds final authority over the change window; gives formal go/no-go signals for each step; determines rollbacks |
| **Inventory Lead** | Maintains physical custody of the equipment register; verifies every chassis is recorded and tagged before exiting the room |
| **Safety Officer** | Enforces ergonomics, PPE compliance, and physical safety; holds unconditional veto and halt authority |
| **Scribe** | Logs exact real-time start and stop timestamps per procedural step; records all deviations, anomalies, and errors |

---

## 26. Course Deliverables and Submissions

| Deliverable | Scope | Contents and Requirements | Weight | Due Date |
| :--- | :--- | :--- | :--- | :--- |
| **Assignment 1** | Individual | Comprehensive Service Level Objective document for a chosen service: defined SLI, measurement mechanics, target percentage, rolling time window, and technical rationale | 5% | Week 4 |
| **Site Walkthrough Record** | Group | Complete set of five containment room physical measurement logs and the group-approved draft rack elevation layout | 3% | 3 days after Session A |
| **Complete Asset Register** | Group | Detailed equipment inventory (one row per serial number) with designated destination pathways and attached photographic evidence | 5% | 5 days after Session B |
| **Asset Handback Pack** | Group | Signed physical asset transfer certificates accompanied by verified NIST-compliant media sanitization certificates for all decommissioned storage hardware | 2% | 5 days after Session B |

---

## 27. Preparation for Week 3

- **Upcoming Lecture Focus**: Week 3: Systems and distributed systems fundamentals for reliability.
- **Opening Question for Next Session**:
  > "If a system gets slower but has not failed, how do we know it is about to - before the users do?"
- **Individual Pre-Session Tasks**:
  - Read Google SRE Book, Chapter 6: *Monitoring Distributed Systems*.
  - Complete Pre-Class Quiz 2 on the LMS.
  - Review core Linux diagnostic utilities: `top`, `vmstat`, `iostat`, `ss`.
- **Field Work Preparations**:
  - Submit access request forms for both upcoming data center sessions.
  - Assign the four operational roles (Change Owner, Inventory Lead, Safety Officer, Scribe) within each project group.
  - Prepare field toolkits: tape measure, LED flashlight, cable labeling printer/tags, digital camera, and printed paper inventory forms.
- **Continuity from Lab 1**:
  - Update system dependency architecture maps with site discoveries from the walkthrough.
  - Compute estimated error budget consumption for the physical move window.
  - Synthesize the sequential power-down schedule from the updated dependency diagram.

---

## 28. References and Standards

### Lecture Literature
- Beyer, B., Jones, C., Petoff, J., & Murphy, N. R. (2016). *Site Reliability Engineering: How Google Runs Production Systems*. O'Reilly Media. Chapter 4: Service Level Objectives.
- Beyer, B., Murphy, N. R., Raurich, D. K., Blank-Edelman, D., Ferguson, G., & Rosenthal, K. (2018). *The Site Reliability Workbook: Practical Ways to Implement SRE*. O'Reilly Media. Chapters 2 & 5.
- Hidalgo, A. (2020). *Implementing Service Level Objectives: A Practical Guide to Slos, Sli-Based Alerts, and Error Budgets*. O'Reilly Media. Chapters 3–5.

### Field Work and Security Standards
- **ISO/IEC 27001:2022**: *Information security, cybersecurity and privacy protection - Information security management systems - Requirements*. Annex A controls: A.5.11, A.5.15, A.7.1–A.7.4, A.7.10, A.7.14, A.8.32.
- **ISO/IEC 27002:2022**: *Information security, cybersecurity and privacy protection - Information security controls*.
- **ISO/IEC 22237 Series**: *Information technology - Data centre facilities and infrastructures*.
- **NIST SP 800-88 Rev. 1**: *Guidelines for Media Sanitization*. National Institute of Standards and Technology.
- University capital equipment procurement, transfer, and disposal policies.

---

## 29. Core Lecture Summary

1. **If you cannot state what "good enough" is, measured from whose side, and over what window, you have not set a target.**
2. **An error budget transforms subjective conflict ("Whose fault is it?") into objective mathematical risk management ("How much risk can we afford to take?").**
3. **Decommissioning physical infrastructure spends a real error budget. Every minute of scheduled or unscheduled downtime draws from the exact same allowance.**
