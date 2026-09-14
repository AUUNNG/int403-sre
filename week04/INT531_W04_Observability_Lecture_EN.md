# INT531: Site Reliability Engineering
## Week 4: Observability I - Metrics and Prometheus

**Course Details:**
- Course: INT531 Site Reliability Engineering
- Session: Week 4 - Observability I: Metrics and Prometheus (Afternoon: Containment Build Preparation)
- Institution: School of Information Technology, King Mongkut's University of Technology Thonburi
- Duration: Lecture 2 hours + Lab 1.5 hours
- Content Updated: 2026

---

## Executive Summary: Today in Three Sentences

1. A metric is counting with a rule attached; choose the wrong type up front and the calculation you want later is simply unavailable.
2. Labels multiply, they do not add; an unbounded label is how a monitoring system takes itself down.
3. A parts list works the same way: every quantity traces to a per-unit rule, and failing on paper beats failing with a server in your hands.

### Lecturer Commentary: The SRE Mentality vs. Reboot Culture

- **The Fallacy of the Quick Reboot:** When a home Wi-Fi router or laptop hangs, users typically power-cycle the device or reinstall the operating system. In modern microservice deployments, engineers often adopt the same flawed mindset: tearing down a container and redeploying it when memory bloats or latency spikes. While the service recovers temporarily, the root cause remains uninvestigated and will inevitably recur.
- **Burning Error Budget Without Learning:** A 5-minute recurring outage every month accumulates to an hour of annual downtime. In SRE practice, Error Budget exists to absorb the calculated risk of deploying new features and architectural improvements, not to subsidize recurring, unaddressed bugs.
- **Hardware-Aware Service Level Objectives:** Real-world systems run on diverse physical hardware. Setting uniform service level objectives (such as 100,000 concurrent sessions) across mismatched machines is an anti-pattern. Engineers must benchmark the specific physical server, establish empirical operational baselines, and define SLIs/SLOs that reflect the hardware reality.

---

## Agenda

1. **Monitoring vs Observability**: How they differ, and why metrics alone are not enough.
2. **Metric Types**: Counter, gauge, histogram, summary - and choosing between them.
3. **Prometheus, the TSDB, and Alertmanager**: The whole stack, the pull model, and TSDB internals.
4. **PromQL and the Cardinality Trap**: Computing an SLI from raw metrics, and what must never be a label.
5. **Install, Configure Targets, and Test**: Eight install steps, `prometheus.yml`, and six acceptance checks.
6. **Lab 4 - Preparing the Build**: Count what exists, compute the BOM, check capacity before installing.

---

## Session Learning Outcomes (SLOs)

| SLO ID | Outcome Description | Mapped CLO |
| :--- | :--- | :--- |
| **SLO 4.1** | Explain how monitoring and observability differ, and the limits of metrics | CLO3 |
| **SLO 4.2** | Choose the metric type that suits what you need to measure | CLO3 |
| **SLO 4.3** | Explain Prometheus's pull model and what it means for detecting dead targets | CLO3 |
| **SLO 4.4** | Write PromQL for an availability SLI and a latency percentile | CLO2, CLO3 |
| **SLO 4.5** | Estimate a metric's cardinality and avoid labels that take the system down | CLO3, CLO5 |
| **SLO 4.6** | Install and configure Prometheus, Alertmanager, and Grafana, and verify against the checks | CLO3, CLO4 |
| **SLO 4.7** | Compute a parts list from per-unit rules and verify capacity before installing | CLO5, CLO7 |

---

## Section 1: Seeing It Before the Users Tell You

*Context: Last week we diagnosed by hand; today we fit permanent instruments.*

### 1.1 Monitoring vs. Observability

Monitoring and observability are not synonyms, and neither replaces the other.

| Aspect | Monitoring | Observability |
| :--- | :--- | :--- |
| **What it answers** | Things you predicted could break (*known-unknowns*) | Things you never anticipated (*unknown-unknowns*) |
| **How it is set up** | Decide in advance what to measure and when to alert | Collect enough detail to ask a new question later |
| **Example question** | "Is CPU above 80% yet?" | "Why are only mobile users at 09:00 slow?" |
| **Main cost** | Configuring and maintaining alerts | Data volume and cardinality |

**Core Takeaway:**
Metrics are cheap and excellent at answering prepared questions, but useless for unprepared ones. This is why logs and traces follow in week 5.

#### Lecturer Commentary: Practical Analogies

- **Classroom Attendance Analogy:**
  - *Monitoring:* Tracking if the classroom headcount exceeds 60 chairs. When 70 students enter, a predefined alarm fires indicating physical capacity overflow.
  - *Observability:* Logging student badge scan timestamps, student study tracks, entry and exit flows, and duration of stay. This rich context allows engineers to investigate unanticipated questions such as: "Why is the 4th-floor hallway congested specifically at 09:15?", enabling informed facility redesigns like installing wider doors or staggering class schedules.
- **Electric Vehicle (EV) Telemetry Analogy:**
  - *Monitoring:* Checking battery state of charge (100% dropping to 80%, then 50%) or vehicle speed on the dashboard.
  - *Observability:* Telemetry tracking instantaneous power draw (kW/h) correlated with regenerative braking (regen) states, driver throttle aggression ("lead foot" habits), incline angles, and thermal trends. Tesla and modern EV telemetry platforms record high-resolution internal logs so engineers can diagnose unexplained range degradation under arbitrary environmental conditions.

---

### 1.2 Metric Types and Choosing Between Them

Pick the wrong type up front and the calculation you want later becomes impossible.

| Type | Behaviour | Use It For | Example Name |
| :--- | :--- | :--- | :--- |
| **Counter** | Only ever increases; resets to zero on process restart | Cumulative counts such as requests or errors | `http_requests_total` |
| **Gauge** | Moves up and down freely | A value at a single point in time: memory, temperature | `node_memory_available_bytes` |
| **Histogram** | Counts observations into configurable buckets | Distributions such as latency; percentiles can be derived | `http_request_duration_seconds_bucket` |
| **Summary** | Computes quantiles directly inside the application client library | When you never need to aggregate across hosts (you cannot) | `rpc_duration_seconds` |

**Rule of Thumb:**
If you want percentiles, use a **histogram**, because it aggregates across hosts. A **summary** does not aggregate across hosts.

#### Lecturer Commentary: Averages vs. Percentiles in High-Concurrency Services

- **The Danger of Mathematical Averages:** A simple average hides critical performance anomalies. If a service handles 100,000 total requests in an hour, an arithmetic mean might show an acceptable response rate. However, a histogram reveals whether 90,000 of those requests arrived in a single 5-minute burst at 09:15, completely saturating worker pools and dropping requests.
- **Summaries vs. Histograms across Multi-Instance Deployments:** Summaries calculate statistical quantiles (like 0.99) locally in the application memory space before export. You cannot mathematically average percentiles across 10 application instances (`(p99_1 + p99_2) / 2` is statistically invalid). Histograms export raw bucket counters (`_bucket{le="..."}`), allowing the central Prometheus server to aggregate buckets across all instances before computing cluster-wide quantiles via PromQL.

---

### 1.3 Prometheus Architecture and the Pull Model

**Prometheus pulls; it is never pushed to.**

```
+-------------------------------------------------------------+
| Targets (Scrape Endpoints)                                  |
| - Your App (/metrics)                                       |
| - node_exporter (:9100)                                     |
| - cAdvisor (:8080)                                          |
| - SNMP exporter (for PDUs)                                  |
+-------------------------------------------------------------+
                               ^
                               | GET /metrics (e.g. scrape_interval: 15s)
                               |
+-------------------------------------------------------------+
| Prometheus Server                                           |
|                                                             |
| +---------------------------------------------------------+ |
| | Local TSDB                                              | |
| | Samples stored as: (metric, labels, timestamp, value)   | |
| +---------------------------------------------------------+ |
|                              |                              |
|                              v                              |
| +---------------------------------------------------------+ |
| | PromQL Engine                                           | |
| | Evaluates queries, rates, percentiles, aggregations     | |
| +---------------------------------------------------------+ |
+-------------------------------------------------------------+
               |                               |
               v                               v
+-----------------------------+ +-----------------------------+
| Grafana                     | | Alertmanager                |
| Dashboards & Visualisation  | | Routing, Grouping, Silencing|
+-----------------------------+ +-----------------------------+
```

#### Time-Series Representation
Every series is uniquely identified by its metric name and label key-value pairs:
```text
http_requests_total{path="/register", status="200", instance="app01"} 198412
```
*Definition:* Metric Name + Labels = One Time Series.

#### The Liveness Property of Pull
Because Prometheus pulls, a target that dies simply stops answering HTTP scrape requests. The built-in synthetic metric `up` automatically goes to `0`. That alone tells you something is wrong without requiring external health checkers.

#### Lecturer Commentary: Scrape Frequency, Pull Dynamics, and Infrastructure Isolation

- **Polling Mechanics:** Every scrape is a straightforward HTTP `GET /metrics` executed on a timer (defaulting to 15 seconds, equivalent to 4 queries per minute). Decreasing this interval to 5 seconds provides finer time resolution but triples data ingestion and storage overhead.
- **The "Capstone Project Mistake" - Architecture Anti-Pattern:** A recurring error among university project teams is co-locating the monitoring stack on the same virtual machine or container host as the application workload. When the application leaks memory or locks the CPU, the entire VM crashes. The monitoring system dies along with the workload, preventing engineers from viewing historical telemetry or diagnosing the cause of failure.
- **Physical Host Segregation:** In this course's lab environment, monitoring is strictly decoupled. For 20 student project groups running workloads on 20 dedicated physical servers, at least one additional, independent 21st server is dedicated entirely to hosting the Prometheus, Alertmanager, and Grafana observability stack.

---

### 1.4 Components of the Prometheus Stack

Five pieces, with responsibilities that do not overlap:

| Component | Responsibility | Default Port | What Breaks Without It |
| :--- | :--- | :--- | :--- |
| **Prometheus server** | Scrapes targets, stores to TSDB, evaluates rules | `9090` | No data and no alerts at all |
| **Exporter** | Translates a system's native runtime metrics into Prometheus exposition format | `9100` (node) | Devices/services speaking other protocols cannot be scraped |
| **Alertmanager** | Routes, deduplicates, groups, inhibits, and delivers notifications | `9093` | Alerts fire inside Prometheus, but nobody is notified |
| **Grafana** | Visualisation, dashboarding, and interactive data exploration | `3000` | Left querying raw numbers through Prometheus expression browser UI |
| **Pushgateway** | Accepts pushed metric values from jobs too short-lived to be scraped | `9091` | Ephemeral batch jobs exit before a scrape happens, recording nothing |

**Caution on Pushgateway:**
Pushgateway is strictly intended for genuinely short-lived batch jobs. Using it as a substitute for scraping long-running services destroys the `up` metric as a liveness signal, as the gateway stays alive even if the job has died.

#### Lecturer Commentary: Component Roles and "Resume Padding" Anti-Patterns

- **Grafana is Not a Database:** Students often mistakenly refer to Grafana as their monitoring store. Grafana is solely a presentation dashboard engine; it stores zero time-series metric data. If the underlying Prometheus TSDB or data source fails, Grafana renders empty panels.
- **CNCF Landscape Over-Engineering:** Browsing the Cloud Native Computing Foundation (CNCF) observability landscape reveals hundreds of specialized projects. Installing dozens of tools simply to display an impressive architecture diagram creates unmaintainable operational drag. Monitoring tools consume compute and memory; observability infrastructure should remain lean, transparent, and purposeful.

---

### 1.5 Inside the Local Time-Series Database (TSDB)

Understanding internal storage explains why memory consumption grows and why restarts can take time:

```
[ Incoming Samples ]
        |
        v
+----------------------------------------------------------+
| Head Block (In-Memory RAM)                               |
| Holds the newest ~2 hours of samples                     |
+----------------------------------------------------------+
        |                                     |
        | Appended first                      | Written every 2 hours
        v                                     v
+------------------------+          +------------------------+
| Write-Ahead Log (WAL)  |          | Persistent Blocks      |
| On Disk                |          | Immutable block dirs   |
| Prevents crash loss    |          | [2h] [2h] [2h]         |
+------------------------+          +------------------------+
                                              |
                                              v
                                    +------------------------+
                                    | Compaction             |
                                    | Merged into 8h blocks; |
                                    | duplicate indexes drop |
                                    +------------------------+
                                              |
                                              v
                                    +------------------------+
                                    | Retention              |
                                    | Blocks deleted whole   |
                                    | (never row-by-row)     |
                                    +------------------------+
```

#### Key Mechanics:
1. **Head Block (in memory):** Holds the newest ~2 hours of incoming samples in RAM.
2. **Write-Ahead Log (WAL on disk):** Every sample is appended to the WAL immediately to survive unexpected crashes.
3. **Persistent Blocks:** Every 2 hours, the head block is flushed to disk as an immutable directory.
4. **Compaction:** Smaller 2-hour blocks are progressively merged into larger 8-hour blocks while redundant index entries are dropped.
5. **Retention:** Whole blocks that fall outside the retention window are deleted entirely from the filesystem (never individual rows).

#### Operational Consequences:
- **Memory consumption** grows with the number of **active time series**, not with the total disk size.
- **Process restarts** replay the WAL from disk into memory; a bloated WAL results in a prolonged restart time.

#### Lecturer Commentary: TSDB Memory Dynamics and Deletion Logic

- **Why Retention Deletes Blocks, Not Rows:** Relational databases often slow down when executing massive `DELETE FROM table WHERE timestamp < ...` operations due to row indexing and lock overhead. Prometheus avoids this entirely: when retention expires (e.g. 15 days), it unlinks and deletes entire 2-hour or 8-hour filesystem directories.
- **WAL Replay Latency:** When a Prometheus server with high active series restarts, it must read and replay every uncompacted record from the disk WAL into RAM to restore in-memory head chunks. If the system crashed under memory pressure, this replay phase can exhaust RAM again immediately, triggering an unrecoverable restart loop.

---

### 1.6 PromQL - Computing SLIs from Raw Metrics

Three primary PromQL queries cover the vast majority of operational reliability engineering:

#### 1. Requests per Second
```promql
rate(http_requests_total[5m])
```
- `rate()` calculates the per-second average rate of increase of a counter over a specified time window.
- It automatically handles counter resets (e.g., when a service restarts from zero).
- **Rule:** Never subtract raw counter values manually.

#### 2. Success Ratio (Availability SLI)
```promql
sum(rate(http_requests_total{status!~"5.."}[5m])) / sum(rate(http_requests_total[5m]))
```
- **Numerator:** Sum of rates of requests whose HTTP status code does not match the regex `5..` (non-server errors).
- **Denominator:** Sum of rates of all HTTP requests.
- **Connection to SRE fundamentals:** This directly implements the SLI equation defined in Week 2.

#### 3. 99th Percentile Latency (p99)
```promql
histogram_quantile(0.99, sum by (le) (rate(http_request_duration_seconds_bucket[5m])))
```
- You **must** aggregate by the `le` (less than or equal) bucket label before calling `histogram_quantile()`.
- Omission of `sum by (le)` calculates a per-instance quantile rather than a cluster-wide service quantile.

#### Lecturer Commentary: AI Assistance and Foundational Understanding

- **The Role of Generative AI in PromQL:** Generative AI tools (ChatGPT, Claude, Copilot) are highly capable at proposing PromQL boilerplate, SLI expressions, or Grafana queries when provided with system architecture context.
- **The Pitfall of Skipping Fundamentals:** Relying blindly on AI outputs without understanding how PromQL aggregates buckets (`le` labels) or handles counter resets leads to silent calculation errors in production dashboards. When AI hallucinates a non-existent PromQL function or misinterprets vector matching, only an engineer with solid foundational understanding can detect and rectify the flaw. Master the manual math first; leverage AI to accelerate execution later.

---

### 1.7 The Cardinality Trap

**The number-one cause of Prometheus server outages in production.**

> **Core Law:** Cardinality multiplies across labels; it never adds.

#### Comparative Calculation:

**Sensible Metric Schema:**
- `path`: 12 distinct values
- `method`: 4 distinct values (GET, POST, PUT, DELETE)
- `status`: 6 distinct values (200, 201, 400, 401, 404, 500)
- `instance`: 20 distinct servers/containers
$$\text{Total Series} = 12 \times 4 \times 6 \times 20 = 5,760 \text{ series}$$
*Status:* Perfectly manageable on a single Prometheus server.

**Careless Metric Schema (Adding a Single High-Cardinality Label):**
- Adding `user_id` with 3,200 active users:
$$\text{Total Series} = 12 \times 4 \times 6 \times 20 \times 3,200 = 18,432,000 \text{ series}$$
*Status:* Catastrophic. Will cause out-of-memory (OOM) crashes and take down the monitoring server.

**Design Rule:**
Labels may **only** contain values from a small, bounded, closed set. User IDs, order IDs, UUIDs, email addresses, and unparameterized URLs must **never** be used as metric labels; they belong exclusively in structured logs and distributed traces.

#### Lecturer Commentary: Wireshark Analogy and Log Routing

- **The Wireshark Packet Capture Analogy:** Running Wireshark on a saturated gigabit network interface without capture filters quickly exhausts system memory and crashes the packet analyzer. Injecting unbounded, high-cardinality labels into Prometheus creates an identical outcome: Prometheus attempts to maintain an active in-memory index for millions of distinct time series.
- **Where High-Cardinality Data Belongs:** When debugging user-specific issues (e.g. tracking specific user IDs, transaction IDs, or stack traces), route this telemetry to log management platforms (such as Graylog, Loki, or Elasticsearch) or distributed tracing engines. Logs store arbitrary unstructured or semi-structured data sequentially without maintaining persistent multi-dimensional indexing trees in RAM.

---

### 1.8 Core PromQL Reference and Daily Usage

| Concept / Construct | Example Syntax | Purpose / Application |
| :--- | :--- | :--- |
| **Instant Vector** | `http_requests_total` | Retrieves a single, most recent sample value per series (current state) |
| **Range Vector** | `http_requests_total[5m]` | Retrieves a range of sample buffers over time; required by `rate()` and `increase()` |
| **Label Selectors** | `{job="api", status=~"5.."}` | `=`: exact match<br>`!=`: not equal<br>`=~`: regex match<br>`!~`: regex mismatch |
| **Aggregation** | `sum by (path) (...)`<br>`sum without (instance) (...)` | `by`: combines series while preserving named labels<br>`without`: drops named labels and preserves the rest |
| **Counter Increase** | `increase(errors_total[1h])` | Calculates the total count increment over a time window |
| **Binary Operators** | `a / b`, `a > 0.99`, `a and b` | Computes ratios, evaluates thresholds against targets, and filters alert triggers |

#### Common Traps:
1. Calling `rate()` on a **gauge** metric (it is mathematically designed only for monotonically increasing counters).
2. Selecting a range window `[T]` shorter than **four scrape intervals** (e.g., setting `[15s]` when scraping every `15s`), which causes rate calculations to fail or drop to zero during minor scrape delays.

---

### 1.9 Worked Storage Mathematics: Sizing Prometheus Disk

**Fundamental Sizing Formula:**
$$\text{Storage} \approx \text{Active Series} \times \left(\frac{1}{\text{scrape\_interval}}\right) \times \text{bytes\_per\_sample} \times \text{retention\_seconds}$$

#### Sizing for the Sensible Model:
- **Active Series:** 5,760
- **Scrape Interval:** 15 seconds (1 sample per series every 15s)
- **Samples per Second:**
  $$\frac{5,760}{15} = 384 \text{ samples/second}$$
- **Bytes per Sample:** $\approx 2 \text{ Bytes}$ (industry rule of thumb after Gorilla delta-of-delta compression)
- **Daily Ingestion Rate:**
  $$384 \text{ samples/s} \times 86,400 \text{ s/day} \times 2 \text{ B} \approx 66,355,200 \text{ B} \approx 66 \text{ MB/day}$$
- **Total Storage (15-Day Retention):**
  $$66 \text{ MB/day} \times 15 \text{ days} \approx 1.0 \text{ GB}$$
  *Result:* Easily housed within any minimal virtual machine or container.

#### Impact of the Cardinality Trap (`user_id`):
- **Active Series:** 18,432,000
- **Samples per Second:**
  $$\frac{18,432,000}{15} \approx 1,228,800 \text{ samples/second}$$
- **Daily Ingestion Rate:**
  $$1.23\text{M samples/s} \times 86,400 \text{ s} \times 2 \text{ B} \approx 212 \text{ GB/day}$$
- **Total Storage (15-Day Retention):**
  $$212 \text{ GB/day} \times 15 \text{ days} \approx 3,180 \text{ GB} \approx 3.18 \text{ TB}$$

---

### 1.10 Dashboard Design: Answering Questions in Top-to-Bottom Order

A well-architected dashboard reads top to bottom without requiring spoken narration.

```
+--------------------------------------------------------------------------------------------------+
| Row 1: Is the service healthy?                                                                   |
| [ Availability SLI vs Target ]    [ Error Budget Remaining ]        [ Requests per Second ]      |
+--------------------------------------------------------------------------------------------------+
| Row 2: How bad is it, and for whom?                                                              |
| [ Latency (p50 / p90 / p99) ]     [ Errors by Status Code ]         [ Traffic by Endpoint ]      |
+--------------------------------------------------------------------------------------------------+
| Row 3: Which underlying infrastructure resource is hurting?                                      |
| [ CPU and Run Queue ]             [ Memory and Swap ]               [ Disk Await & Network Drops]|
+--------------------------------------------------------------------------------------------------+
```

#### Core Design Principles:
- **Top row visible without scrolling:** Vital high-level health state must be immediately apparent.
- **One question per panel:** Do not clutter single graphs with unrelated measurements.
- **Synchronized time range:** All panels on a dashboard must reflect identical time bounds.
- **Narrative flow:**
  1. *Is it broken?* (Row 1)
  2. *How badly and where?* (Row 2)
  3. *What physical or virtual resource is causing it?* (Row 3)

#### Lecturer Commentary: The Task Manager Anti-Pattern and Inter-Team Blame

- **The Activity Monitor / Task Manager Flaw:** Opening Windows Task Manager or macOS Activity Monitor presents hundreds of disaggregated processes (e.g. WindowServer using high CPU or Chrome consuming gigabytes of RAM). This interface does not tell you if your core business service is functioning properly. A production dashboard cannot simply be a raw list of host processes; it must synthesize metrics into a structured narrative.
- **Bridging the Infrastructure vs. Application Divide:** In enterprise operations, infrastructure administrators frequently deflect service tickets by showing low CPU utilization on the front-end reverse proxy, claiming: "The servers and network are green; the problem must be in your application code." An end-to-end, top-to-bottom dashboard visualizes the entire request journey (from edge ingress down to backend database replica latency), preventing cross-team finger-pointing during critical outages.

---

### 1.11 Case Study 1: When the Monitoring System Took Itself Down

A typical post-mortem timeline seen repeatedly across engineering teams:

- **Day 0 · 14:20:** A debugging label is added. An application developer attaches `order_id` to an HTTP metric to track a subtle production bug. The change passes review and deploys.
- **Day 0 · 16:40:** Active series count climbs exponentially from 40,000 to 900,000 within two hours. No alerts are configured to monitor the monitoring system itself.
- **Day 1 · 02:10:** Prometheus runs out of memory and is terminated by the Linux OOM killer. The container restarts, begins replaying its bloated write-ahead log (WAL), exhausts RAM again, and enters a crash loop.
- **Day 1 · 02:10:** Alerting goes completely silent. A real database outage occurs at 03:00 and remains completely undetected for 50 minutes until customers flood support channels.
- **Day 1 · 09:30:** Recovery achieved after the offending metric label is dropped from application code, corrupted/bloated TSDB data is wiped, and an explicit alert on total series count is implemented.

#### Lessons Learned:
1. **The monitoring system needs monitoring:** Configure high-priority alerts on `prometheus_tsdb_head_series` and Prometheus memory consumption.
2. **Every label addition is an architectural decision:** Adding a label is a capacity and cardinality choice, never mere logging formatting.
3. **Loss of observability is a Sev-1 incident:** Even if user-facing applications appear functional, running blind is an emergency.

---

### 1.12 Observability for Physical Data Centre Infrastructure

Physical infrastructure carries metrics, telemetry, and SLOs just like application services.

| Infrastructure Telemetry | Metric Type | Collection Mechanism | Operational Decision Driven |
| :--- | :--- | :--- | :--- |
| **PDU load per phase (Amperes)** | Gauge | SNMP exporter on Intelligent PDU | Determines headroom for installing additional physical servers |
| **Rack inlet & outlet temperature** | Gauge | In-rack environmental sensors via SNMP | Confirms cold/hot aisle containment integrity |
| **PSU operational status** | Gauge (0/1) | IPMI or Redfish exporter | Detects servers running without power redundancy on a single feed |
| **ToR switch ports in use** | Gauge | SNMP exporter on Top-of-Rack switch | Dictates procurement triggers for additional network switches |

#### Lecturer Commentary: SNMP Architecture and Real-World Power Economics

- **SNMP Polling Mechanics:** Simple Network Management Protocol (SNMP) functions analogously to Prometheus HTTP scraping. Enterprise switches, PDUs, and server management controllers run internal SNMP daemon agents that store hardware telemetry in Management Information Bases (MIBs). The Prometheus `snmp_exporter` periodically polls these endpoints and converts them into standard Prometheus metrics.
- **Power Sizing Scale Comparison:**
  - *Rural / Modest Home:* 5 Amperes main breaker.
  - *Modern Urban Residence:* 15 Amperes single-phase breaker.
  - *House with EV Charger:* 100 Amperes with dedicated secondary electrical circuits.
  - *Colocation Data Centre Rack:* Typically rented with 16 Amperes or 32 Amperes feeds.
- **Colocation Cost Context:** Renting a single standard 42U rack space with a 16A power feed at enterprise data centres (such as CAT Telecom or JAS TEL) costs approximately 50,000 THB per month for empty rack space and electrical utilities alone, excluding the cost of servers and software.
- **Power Supply Density:** Older servers utilized 350W–500W power supplies. High-performance enterprise compute and GPU-accelerated nodes require dual 1,000W–2,000W 80 Plus Platinum power supplies. Running multiple multi-PSU servers on a single 16A feed risks exceeding thermal limits and tripping main breakers.

---

### 1.13 Grafana Best Practices

Four essential fundamentals for robust Grafana setups:

1. **Data Source Configuration:**
   - In containerized environments, point to Prometheus using its Docker network service name (`http://prometheus:9090`), never `localhost`.
2. **Panels and Queries:**
   - Title panels with the question being answered, not the metric name.
   - Always configure explicit unit definitions (e.g., seconds, bytes, percent) so axes render meaningfully.
3. **Template Variables:**
   - Utilize `$job` and `$instance` variables to create reusable, dynamic dashboards instead of cloning static dashboards per server.
4. **Declarative Provisioning:**
   - Store dashboard JSON definitions and data source configs in Git repositories.
   - Configure Grafana's file provisioning engine to load dashboards automatically on startup.
   - *Rule:* A dashboard created manually in the UI and never committed to Git disappears when the container terminates.

---

### 1.14 Alertmanager: Routing, Grouping, and Notification Hygiene

The alerting pipeline is designed to turn a cascaded system failure into a single actionable notification.

```
[ Alerting Rules in Prometheus ]
Evaluated on fixed interval; must remain firing for 'for: <duration>'
              |
              v
[ Alertmanager Pipeline ]
  1. Route:    Evaluates label matching tree (severity, team, service); first match wins
  2. Group:    Aggregates matching alerts sharing 'group_by' over 'group_wait' window
  3. Inhibit:  High-level alerts suppress lower-level alerts (e.g., RackDown suppresses HostDown)
  4. Silence:  Time-bounded human mute for planned maintenance windows
              |
              v
[ Notification Receivers ]
Email  |  Slack / Microsoft Teams  |  PagerDuty / Webhooks
```

**Anti-Alert Fatigue Rule:**
Alertmanager exists so that a single switch outage produces one concise incident notification rather than forty individual host unreachable pages.

#### Lecturer Commentary: Alert Fatigue and Notification Psychology

- **Alerts vs. Notifications:**
  - *Alert:* Signifies an acute failure or critical threshold violation that demands immediate human intervention.
  - *Notification:* General informational updates that do not require emergency action.
- **The Psychology of Notification Fatigue:** In modern messaging environments, users often accumulate 999+ unread chat badges on platforms like LINE or Discord, eventually tuning them out entirely. When an SRE monitoring system configures noisy, low-severity alerts for every minor transient fluctuation, on-call engineers become desensitized. Critical Sev-1 alerts are overlooked simply because alarms fire continuously.
- **Alert Ingestion Rule:** If an alert does not require immediate operational action, it should not trigger a pager or emergency message; it belongs on a weekly review report or dashboard.

---

### 1.15 Prometheus Stack Installation Workflow

An eight-step deployment sequence requiring approximately 30 minutes:

```
Step 1: Lay out directory structure (monitoring/ with subdirs: prometheus, alertmanager, grafana)
   |
Step 2: Write docker-compose.yml defining prometheus, alertmanager, grafana, node-exporter
   |
Step 3: Write prometheus.yml with global scrape intervals and target configurations
   |
Step 4: Validate syntax offline: promtool check config prometheus.yml
   |
Step 5: Launch containers: docker compose up -d (verify container health)
   |
Step 6: Inspect Prometheus targets UI: http://localhost:9090/targets (all UP)
   |
Step 7: Validate queries via UI: verify 'up' and 'rate(...)' return non-empty datasets
   |
Step 8: Connect Grafana: configure Prometheus data source and build dashboards from validated queries
```

---

### 1.16 Standard Configuration File: `prometheus.yml`

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - /etc/prometheus/rules/*.yml

alerting:
  alertmanagers:
    - static_configs:
        - targets: ['alertmanager:9093']

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node'
    static_configs:
      - targets: ['node-exporter:9100']
    labels:
      rack: 'CT-01'
      room: 'CB-204'
```

#### Configuration Principles:
- `job_name` becomes an immutable label on every scraped metric; name it thoughtfully.
- Static target labels attach physical and organizational topology (e.g., `rack`, `room`) directly to time series.
- In Docker Compose networks, target hostnames must match service names (`node-exporter:9100`), not `localhost`.
- Limit external static labels to avoid multiplying series cardinality unnecessarily.

---

### 1.17 Six Acceptance Verification Checks

All six verification criteria must pass before an installation can be declared production-ready:

| Step / Verification Item | Execution / Command | Acceptance Criteria |
| :--- | :--- | :--- |
| **1. Config Validity** | `promtool check config prometheus.yml` | Must report `SUCCESS` with 0 syntax or parsing errors |
| **2. Target Scraping** | Navigate to `/targets` in browser | Every target reports state `UP` with scrape time within one interval |
| **3. Real Metric Values** | Query `up` in PromQL console | Returns numeric value `1` for each defined target |
| **4. Rate Computation** | Query `rate(node_cpu_seconds_total[5m])` | Returns computed rates, not an empty result vector |
| **5. Rule Loading** | Navigate to `/rules` | All alert and recording rules are loaded without parsing errors |
| **6. Alert Delivery** | Dispatch synthetic test alert into Alertmanager | Notification is successfully received at the destination endpoint |

*Note:* Check 6 is the most frequently neglected test, yet it is the only check that proves the alert dispatch pipeline works end-to-end.

---

## Section 2: Lab 4 - Preparing the Containment Build

*Context: The old rack is empty; today we count, compute, and verify whether the physical plan fits.*

### 2.1 Project Status: Week 3 to Week 4 Transition

- **Completed:** All existing hardware has been decommissioned from the legacy rack, inventoried under `INV-01` and `MED-01`, and staged by target destination.
- **Today's Objective:** Conduct a physical count of existing inventory, calculate procurement requirements, and verify rack unit (U) and electrical capacity limits.
- **Pending:** Physical installation into the containment rack begins only after the Bill of Materials (BOM) is validated and open technical items are resolved.
- **Core Constraint:** Approximately 10 additional servers will arrive in unscheduled phases; the install layout must tolerate partial delivery.

---

### 2.2 Five-Layer Data Centre Physical Model

Physical facility engineering must be planned from top down, but installed from bottom up:

```
Layer 5: Monitoring  --> Which metrics do we poll? (PDU current, inlet temp, PUE)
   ^
   |
Layer 4: Network     --> Port media types, patch panels, cable lengths, spare uplinks
   ^
   |
Layer 3: Power       --> Feeds, UPS circuits, PDU A/B branch limits, inrush currents
   ^
   |
Layer 2: Racks & Air --> Cold/hot aisle containment, U slot assignments, blanking panels
   ^
   |
Layer 1: Floor & Path--> Floor tile point loading, cable basket trays, clearance widths
```

> **Planning Maxim:**
> Plan top-down, build bottom-up. Decisions flow from monitoring back to the floor, but installation starts at the floor and works up. A layer that was never decided becomes a layer that gets improvised on the day.

---

### 2.3 Translating 20 Student Groups into a Bill of Materials (BOM)

```
                       [ 20 Student Groups Target Capacity ]
                                         |
     +-------------------+---------------+-------------------+-------------------+
     |                   |                                   |                   |
     v                   v                                   v                   v
[ Blade Chassis ]  [ Bare-Metal Servers ]            [ Future Servers ]    [ Network Layer ]
8 groups (1 chassis) 3-5 groups (to confirm)          ~10 servers (phased)  2 ToR Switches
     |                   |                                   |                   |
     +-------------------+---------------+-------------------+-------------------+
                                         |
                                         v
   +-------------------------------------------------------------------------------+
   | Mounting:     Rails, cage nuts (M6), mounting screws, blanking panels         |
   | Cabling:      Cat6A patch cords, Direct Attach Copper (DAC), optical fibre    |
   | Power:        C13-C14 jumpers, C19-C20 cords, redundant PDU outlets           |
   | Accessories:  SFP+ optical transceivers, plug adapters, shelf kits            |
   +-------------------------------------------------------------------------------+
```

**Rule:** Every single quantity on the BOM must derive from a deterministic per-unit calculation rule, never an estimate or guess. Unknown quantities must be explicitly recorded as open items.

---

### 2.4 Per-Unit Hardware Consumption Rules

| Component | Per-Unit Formula | Technical & Compliance Justification |
| :--- | :--- | :--- |
| **Rail Kits** | 1 kit per rack-mounted chassis/server/switch | Every physical chassis, bare-metal server, and ToR switch requires its own rails |
| **Cage Nuts & Screws** | 8 nuts and 8 screws per device | 4 per mounting flange/post across front and rear vertical rails |
| **Blanking Panels** | $1\text{U}$ panel per $1\text{U}$ of unoccupied space | Every vacant slot must be sealed to stop hot exhaust recirculation into cold aisle |
| **Power Cords** | 1 cable per Power Supply Unit (PSU) | Redundant dual-PSU devices must route cord 1 to PDU A and cord 2 to PDU B |
| **Data Cables** | 1 patch lead per active interface | Bare-metal server standard: 2 data ports (LACP bond) + 1 IPMI out-of-band port |
| **Cable Labels** | 2 labels per cable (one at each termination) | ISO/IEC 27001 Control A.7.12 requires both ends to be distinctly labelled |
| **SFP+ Transceivers** | 2 optical modules per fibre run | One transceiver required at ToR switch port, one at upstream core switch port |

---

### 2.5 First-Pass Capacity Assessment (Baseline Numbers)

Initial calculations based on preliminary estimates:

| Planning Dimension | Baseline Calculation | Threshold / Capacity | Validation Result |
| :--- | :--- | :--- | :--- |
| **Groups Supported** | 22 groups (8 blade + 4 bare + 10 phased) | Target: 20 groups | **PASS** (+2 headroom) |
| **Rack Units (U)** | 44U total space required | Rack size: 42U | **FAIL** (Deficit: 2U) |
| **Total Power Draw** | 9,200 Watts calculated | Usable limit: 2,944 W / PDU | **FAIL** (Substantial overrun) |
| **PDU Outlets** | 36 outlets required | Available: 48 outlets (2x24) | **PASS** (12 spare) |

**Engineering Lesson:**
Discovering capacity deficits on paper is the desired outcome. Resolving failures mathematically on the BOM avoids physical halts during rack deployment.

---

### 2.6 Case Study 2: Power-On Inrush Current and Tripped Breakers

An identical engineering failure occurs when physical power dynamics are ignored:

- **Calculated Steady-State Load:** 9,200 W
- **Branch Circuit Breaker Rating:** 16 Amperes
- **Inrush Surge Characteristic:** At cold power-on, switch-mode power supplies exhibit inrush spikes of **3x to 5x steady-state current** for several hundred milliseconds to charge internal capacitors.

```text
Current (A)
   ^
60 |      /\  [ All At Once: Spikes to 60A - BREAKER TRIPS ]
   |     /  \
50 | - -/ - - - - - - - - - - - - - - - - - - - - - - - - - [ Trip Threshold: 50A ]
40 |   /     \__________________________________ [ Steady-state: 40A ]
   |  /
30 | /            _/\_          _/\_
   |/            /    \        /    \
20 |   _/\_     /      \______/      \__________ [ Staggered Power-On: Max 40A ]
   |  /    \___/
10 | /
 0 +------------------------------------------------------------> Time (s)
```

**Mitigation:**
Implement sequential or staggered power-on sequences (e.g., energizing servers in batches of four, separated by 30-second intervals). This eliminates transient current summing without hardware cost.

---

### 2.7 Impact of Unverified Assumptions (Recount Scenario)

Illustrating the impact when unverified assumptions are corrected:

| Planning Parameter | Initial Estimate | Confirmed Physical Count | Resulting Architecture Consequence |
| :--- | :--- | :--- | :--- |
| **Bare-metal groups** | 4 groups | 5 groups | Adds 1 server chassis, extra rail kit, power cords, DAC cabling |
| **Chassis Blade Capacity** | 8 slots | 6 slots | 8 blade groups require 2 chassis instead of 1 |
| **Chassis Units Needed** | 1 chassis | 2 chassis | Consumes an additional 10U of rack space and 4 additional PSUs |
| **Total Rack Units** | 44U | 56U | Exceeds 42U rack capacity by 14U; necessitates a 2nd rack or phased rollout |
| **Total Power Draw** | 9,200 W | 12,800 W | Drastically exceeds single circuit capacity; requires multi-phase power |

---

### 2.8 Strategic Remediation Options for Capacity Deficits

Every mitigation decision involves architectural trade-offs and must be documented via formal Change Request (`CR-01`):

#### When Rack Units Fall Short:
1. Mandate high-density 1U chassis rather than 2U servers for upcoming procurements.
2. Phase the hardware deployment, installing only what current space accommodates.
3. Formally request allocation of a second adjacent containment rack.
4. Reduce dedicated cable management and patch panel allowances from 4U to 2U.

#### When Electrical Power Falls Short:
1. Install supplemental electrical feeds and branch PDUs to support the aggregate load.
2. Upgrade single-phase distribution to three-phase 400V/16A or 32A PDU infrastructure.
3. Configure programmable PDU outlet sequencing to suppress simultaneous inrush spikes.
4. Validate actual nameplate ratings using hardware wattmeter measurements rather than conservative theoretical maximums.

---

### 2.9 Eight Mandatory Technical Open Items

Before procurement orders can be submitted, eight open technical unknowns must be resolved:

1. **Exact Bare-Metal Group Count (3, 4, or 5):** Dictates rails, power jumpers, DAC cables, and U height.
2. **Blade Chassis Model & Slot Density:** Verifies if one chassis suffices or if a second 10U chassis is necessary.
3. **Delivery Schedules for ~10 Incoming Servers:** Determines whether deployment occurs in a single build or staged batches.
4. **ToR Switch Port Form Factor (SFP+ vs. 10GBASE-T RJ45):** Determines cable media selection (DAC twinax vs Cat6A twisted pair).
5. **Real Device Nameplate Power:** Replaces conservative engineering estimates with empirical wattage readings.
6. **Rack Depth and Vertical Rail Hole Specification:** Verifies compatibility of slide rails with square-hole or threaded rack posts.
7. **Usable PDU Receptacle Count:** Audits available C13 and C19 outlet counts on existing rack PDUs.
8. **Cable Pathway Distance to Main Distribution Frame (MDF):** Establishes optical patch cord lengths along actual cable trays.

---

### 2.10 Compliance Controls (ISO/IEC 27001:2022 Annex A)

| Control Standard | Control Title | Practical Lab Enforcement |
| :--- | :--- | :--- |
| **A.5.9** | Inventory of Assets | All newly arrived physical devices must be formally catalogued in `INV-01` prior to unboxing |
| **A.5.10** | Acceptable Use of Assets | Hardware drawn from storage must only serve designated lab workloads; surplus returns to inventory |
| **A.7.8** | Equipment Siting and Protection | Rack elevation layout (`RACK-01`) must receive technical approval before mounting hardware |
| **A.7.11** | Supporting Utilities | Electrical load calculations and cooling capacity must be verified before energizing equipment |
| **A.7.12** | Cabling Security | Data and power cabling must occupy separate pathways; every cable termination must bear dual labels |
| **A.8.32** | Change Management | All deviations, modifications, and installation steps require approved `CR-01` forms with rollback procedures |

---

### 2.11 Lecturer Commentary: Field Context and Lab Hardware Realities

#### 1. Hardware Origin and Physical Architecture
- **Repurposed Enterprise Assets:** The lab hardware consists of enterprise Fujitsu Primergy blade servers and standalone 1U rack servers salvaged from faculty decommissioning (previously slated for scrap metal recycling). This equipment provides authentic data centre operations practice.
- **Blade Enclosure Architecture:**
  - The central chassis accommodates 8 blade server sleds.
  - Sleds feature dual Intel Xeon sockets, multi-channel registered ECC server RAM (cannot be used in desktop PCs), and hot-swap SAS drive bays (e.g. dual 300GB 10K/15K RPM SAS drives).
  - The rear backplane houses hot-swappable 80 Plus Platinum redundant power supplies, redundant fan modules, integrated pass-through or managed SAN switches (Fibre Channel), and Top-of-Rack network switch interconnect modules.
- **Standalone 1U Servers:** Fujitsu 1U rackmount units provide dedicated bare-metal infrastructure for teams outside the blade chassis.

#### 2. Physical Handling and Mechanical Precautions
- **Latch and Lever Fragility:** Students must exercise care with server insertion levers and locking latches. Forcing blades into backplanes without aligning guide pins bends pins or snaps extraction levers (an issue encountered in prior semesters).
- **Structural Integrity:** Heavy server chassis must never be stacked loosely on classroom tables; they must be staged on dedicated floor areas or securely mounted on rack rails.
- **Rack Mount Compatibility:** Ensure rail kits match rack post geometry (cage-nut square holes vs. pre-threaded round holes) before installation.

#### 3. Storage Arrays and Software Obsolescence
- The lab inventory includes 3 legacy SAN/NAS disk storage enclosures (1 SSD-based array and 2 spinning HDD arrays).
- **The Management Utility Trap:** The management software for these older storage controllers requires legacy operating systems (Windows XP or Windows 7) to run proprietary configuration utilities. The lecturer advises students to prioritize direct-attached SSD storage and avoid wasting time debugging obsolete storage management software unless specifically exploring legacy SAN protocols.

#### 4. The Hypervisor Layer: Proxmox VE
- **True Site Administrator Ownership:** In earlier coursework, students operated inside pre-provisioned virtual machines managed by faculty infrastructure administrators. In INT531 SRE, students take complete bare-metal ownership of physical hardware: configuring BIOS/UEFI settings, setting up IPMI/iRMC out-of-band management, partitioning disks, wiring patch panels, configuring VLANs, and deploying hypervisors via bootable USB drives.
- **Why Proxmox VE was Chosen:**
  - *Microsoft Hyper-V:* Incurs software licensing costs and platform constraints.
  - *VMware ESXi:* Industry licensing restructuring under Broadcom created uncertainty and steep costs, prompting widespread migration across enterprise infrastructure.
  - *Proxmox VE:* Open-source, lightweight, robust Debian-based Linux KVM/LXC virtualization platform with native clustering, web GUI, and REST APIs, well-suited for modern on-premises infrastructure.

---

### 2.12 Definition of Done for Week 4 Lab

Before the laboratory session concludes, five verification milestones must be signed off:

- [ ] **BOM Verification:** The group's Bill of Materials has the "already have" column populated from an empirical hardware count (*Inventory Lead*).
- [ ] **Capacity Sheet Completion:** The capacity worksheet is calculated and explicitly identifies failing lines (*Technical Reviewer*).
- [ ] **Remedy Selection:** Documented engineering justifications and remedies are established for all failing parameters (*Change Owner*).
- [ ] **Open Item Ownership:** All eight open technical items are assigned to designated owners with firm resolution deadlines (*Change Owner*).
- [ ] **Asset Segregation:** Inventoried and counted hardware parts are neatly stored, labeled, and isolated from other groups (*Safety Officer*).

---

### 2.13 Course Deliverables and Next Week's Preparation

#### Group Assignments (Due in 5 Days):
1. Complete BOM workbook with capacity calculations fully balanced and passing on all lines.
2. Technical justification documentation detailing selected remedies (minimum 3 lines of reasoning per failing dimension).
3. Resolution evidence for all 8 open items (e.g., chassis serial photos, nameplate wattages).
4. Completed draft Change Request (`CR-01`) for scheduled physical installation.

#### Individual Preparation (Before Next Session):
1. Read *Observability Engineering* (Charity Majors et al.), Chapters 1–3.
2. Complete LMS Pre-Class Quiz 4.
3. Deploy Prometheus and Grafana stack locally; submit verification screenshot of `/targets` showing `up == 1`.
4. Compose a single-line PromQL query calculating your application's availability SLI.

#### Preview for Week 5:
- Topic: **Observability II — Structured Logs and Distributed Tracing**.
- *Opening Discussion Question:* "Metrics can tell you that 1% of requests failed, but not whose requests failed or at which microservice step they broke — what else do we need to collect?"

---

### 2.14 Academic and Technical References

- Beyer, B., Jones, N. R., Petoff, J., & Murphy, N. R. (2016). *Site Reliability Engineering: How Google Runs Production Systems*. O'Reilly Media. Chapter 6: Monitoring Distributed Systems.
- Majors, C., Fong-Jones, L., & Miranda, G. (2022). *Observability Engineering: Achieving Operational Excellence*. O'Reilly Media. Chapters 1–3.
- Prometheus Documentation: Metric Types, PromQL Basics, and Exporter Guidelines.
- Grafana Labs Documentation: Dashboard Best Practices and Provisioning Workflows.
- ISO/IEC 27001:2022: Information Security Management Systems — Annex A Controls (A.5.9, A.5.10, A.7.8, A.7.11, A.7.12, A.8.32).
- ISO/IEC 22237 Series: Information Technology — Data Centre Facilities and Infrastructures.
