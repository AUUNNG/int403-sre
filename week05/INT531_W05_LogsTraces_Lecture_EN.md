# INT531: Site Reliability Engineering
## Week 05: Observability II - Logs and Distributed Tracing

School of Information Technology, King Mongkut's University of Technology Thonburi  
Lecture: 1.5 hours | Field Lab: 1.5 hours | Content Updated: 2026  
Schedule: Morning - Collecting what metrics cannot say | Afternoon - Installing into the rack  

---

## Table of Contents
1. [Agenda and Learning Outcomes](#agenda-and-learning-outcomes)
2. [Section 1: The Gap Metrics Cannot Fill](#section-1-the-gap-metrics-cannot-fill)
3. [Section 2: Logs That Are Actually Usable](#section-2-logs-that-are-actually-usable)
4. [Section 3: Loki and the Label Trap](#section-3-loki-and-the-label-trap)
5. [Section 4: Distributed Tracing](#section-4-distributed-tracing)
6. [Section 5: Joining the Three Pillars](#section-5-joining-the-three-pillars)
7. [Section 6: Lab 5 - Installation Day](#section-6-lab-5---installation-day)
8. [Assignments and Next Week](#assignments-and-next-week)
9. [References and Standards](#references-and-standards)
10. [Summary: Today in Three Sentences](#summary-today-in-three-sentences)

---

## Agenda and Learning Outcomes

### Agenda Overview
- 01: The gap metrics cannot fill - Why we know 1% failed but not whose request it was
- 02: Logs that are actually usable - Structured logging, levels, sampling, and cost
- 03: Loki and the label trap - The same rule as Prometheus, missed a second time
- 04: Distributed tracing - Spans, trace context, OpenTelemetry, and sampling
- 05: Joining the three pillars - One trace_id threading metrics, logs, and traces together
- 06: Lab 5 - Installation day - Into the containment rack: mount, cable, power on, accept

### Session Learning Outcomes (SLO)
| Outcome Code | Description | Mapped Course Learning Outcome (CLO) |
| :--- | :--- | :--- |
| SLO 5.1 | Explain what metrics, logs, and traces each answer, and choose the right one | CLO3 |
| SLO 5.2 | Write structured logs that are searchable, at an appropriate level | CLO3 |
| SLO 5.3 | Explain Loki's label trap and design labels that are safe | CLO3, CLO5 |
| SLO 5.4 | Read a trace waterfall and say where the time actually went | CLO5 |
| SLO 5.5 | Explain trace sampling and its effect on what you can investigate later | CLO3 |
| SLO 5.6 | Install equipment to an approved layout and verify it against acceptance criteria | CLO4, CLO7 |

---

## Section 1: The Gap Metrics Cannot Fill

### Core Principle
Metrics say there is a problem; they cannot say to whom, or where.

### Three Questions Metrics Cannot Answer
Case study based on an incident in the Speech-to-Text (STT) service:

1. **"Why did this one lecturer's session fail?"**
   - Metrics are aggregate calculations over time.
   - We observe that 1% of total requests failed, but we cannot isolate or trace back to that specific session.
   - Root cause in monitoring design: `session_id` was deliberately omitted from metric labels to avoid high cardinality.

2. **"Where did those 3.2 seconds go?"**
   - The latency histogram reports an aggregate total duration of 3.2 seconds.
   - It cannot reveal that 1.66 seconds was spent waiting in the GPU job queue, while only 0.45 seconds was actual model inference.

3. **"What happened just before it broke?"**
   - Metrics scrape at intervals (e.g., every 15 seconds).
   - Events occurring between scrape intervals are unrecorded: specific error messages, call ordering, stack traces, and transient state changes are lost.

*Conclusion:* None of these gaps is resolved by adding more metrics. They are fixed by collecting different classes of observability data.

### The Three Pillars of Observability
Each observability pillar entails different operational costs and answers a fundamentally distinct question.

| Feature / Dimension | Metrics | Logs | Traces |
| :--- | :--- | :--- | :--- |
| Primary Question Answered | How much, how often, how bad | What exactly happened, in order | Where the time went, across services |
| Cost Profile | Cheap: few bytes per sample | Expensive: full text per event | Sampled: typically 1% to 10% of requests |
| Data Structure | Aggregated numeric values over time; no individual request records | One record/line per event; preserves exact granular detail | Directed acyclic graph (tree) per request with span timings |
| Operational Limit | Cardinality is the hard limit | Volume and ingestion bandwidth is the hard limit | Instrumentation effort and engineering overhead is the limit |
| Investigative Focus | Answers questions prepared in advance | Answers "what did this request do?" | Answers "which hop was slow?" |

#### Decision Rule: Selecting the Right Pillar
- *"Is the service healthy?"* -> Query **Metrics**.
- *"Why did this one session fail?"* -> Query **Logs**.
- *"Which step took the 3 seconds?"* -> Query **Traces**.

#### Critical Synthesis Note
All three pillars must be connected using the identical `trace_id`. Without a common trace identifier, observability data remains three isolated piles of information that cannot be correlated into a coherent incident timeline.

---

## Section 2: Logs That Are Actually Usable

### Core Principle
A log that reads nicely to human eyes but cannot be indexed or searched by machine is useless during an outage at 2:00 AM.

### Structured Logging: Write for the Machine
Structured logging transforms arbitrary human prose into strongly typed, machine-parseable key-value pairs.

#### Comparison: Unsearchable vs. Searchable Formats

- **Unsearchable Form (String Interpolation):**
  ```python
  logger.info(f"transcribe failed for {sid} after {ms}ms")
  ```
  - Problem: During an incident at 2:00 AM, engineers must craft complex regular expressions to extract metrics, session IDs, and durations.
  - Fragility: Any minor modification to text formatting or wording breaks existing parsing alerts and log ingestion pipelines.

- **Searchable Form (Structured Event):**
  ```python
  logger.info("transcribe_failed", extra={
      "session_id": sid,
      "engine": "whisper-small",
      "duration_ms": ms,
      "error": "gpu_timeout",
      "trace_id": ctx.trace_id
  })
  ```
  - Benefit: Queries can filter directly on structured fields (e.g., `error = "gpu_timeout"`, `duration_ms > 2000`).
  - Correlatability: The included `trace_id` allows immediate cross-navigation to distributed tracing waterfalls.

### Three Essential Elements of Every Log Line
1. **UTC Timestamp with Explicit Units:** Systems run across diverse hardware environments and timezones. Timestamps must be recorded in UTC with standard ISO 8601 formatting.
2. **Trace Identifier (`trace_id`):** Allows an engineer to navigate instantly from a log error line to the complete trace context of that request.
3. **Stable Event Identifier:** Use static, standardized machine tokens (such as `transcribe_failed`) rather than mutable prose sentences, ensuring downstream search queries and dashboards remain stable.

### Log Levels and Volume Guidelines
Assigning incorrect log levels drives log storage and ingestion costs up tenfold without operational benefit.

| Log Level | When to Use | Example in STT Service | Expected Share of Volume |
| :--- | :--- | :--- | :--- |
| `ERROR` | Work failed completely; requires human intervention | Model failed to load; unable to persist audio transcription result | Under 0.1% |
| `WARN` | Abnormal situation occurred, but execution continued | Queue depth exceeded soft threshold resulting in dropped audio frames; retry triggered | Under 1% |
| `INFO` | Significant lifecycle events that must be reconstructible later | Session started; session completed; transcription model loaded into memory | Approximately 5% to 10% |
| `DEBUG` | Granular debugging details required solely for chasing a specific problem | Byte size of each audio chunk; exact parameters passed to inference model | Disabled in production environments |

#### Production Rule of Thumb
If turning on `DEBUG` logging in production increases total log volume by more than tenfold, the debug statements are mislocated. The logging platform is not at fault; the code contains excessive diagnostic chatter.

---

## Section 3: Loki and the Label Trap

### Core Architectural Principle
Grafana Loki indexes metadata labels only; it never creates a full-text index of the message body.

### Log Processing Pipeline
```
[ Application ]
  - Emits JSON logs (one line per event)
        |
        v
[ Agent (Grafana Alloy or Promtail) ]
  - Tails log files and attaches stream labels
        |
        v
[ Grafana Loki ]
  - Indexes stream labels only
  - Stores compressed log chunks in object storage
        |
        v
[ Grafana UI ]
  - Queries via LogQL
  - Extracts fields at query time
  - Deep-links to correlated traces via trace_id
```

### Label Safety: Safe Labels vs. Dangerous Labels
Because Loki creates an independent stream index for every unique combination of label keys and values, label design rules in Loki mirror Prometheus cardinality constraints:

- **Safe Labels (Bounded Cardinality):**
  - Examples: `service`, `env`, `level`, `engine`
  - Characteristics: A small, finite set of predictable values.
- **Dangerous Labels (High Cardinality - Crashes Loki):**
  - Examples: `session_id`, `user_id`, `trace_id`, `request_path`
  - Consequence: Unbounded values create millions of discrete streams, causing metadata index exhaustion and Out-Of-Memory (OOM) crashes.

*The Rule:* High-cardinality values (`session_id`, `trace_id`) belong inside the JSON message payload, never in Loki stream labels. Filter them dynamically using LogQL string and JSON filters.

### Three Essential LogQL Query Patterns

1. **Filter Text Within a Specific Service Stream:**
   ```logql
   {service="live-stt", level="error"} |= "gpu_timeout"
   ```
   - *Operational Guideline:* Always narrow the query stream using indexed labels first (`service`, `level`), then filter the payload text with the `|=` operator. Querying without stream constraints forces Loki to scan massive amounts of compressed chunk data.

2. **Parse JSON Payloads and Filter Numerically:**
   ```logql
   {service="live-stt"} | json | duration_ms > 2000
   ```
   - *Operational Guideline:* Works seamlessly because the log lines are structured JSON. Unstructured prose requires fragile, compute-heavy regular expressions.

3. **Derive Metric Rates Directly from Logs:**
   ```logql
   sum by (error) (
     rate({service="live-stt"} | json | level="error" [5m])
   )
   ```
   - *Operational Guideline:* LogQL allows real-time metric generation from log lines before formal instrumentation is written. However, if this metric is required permanently, migrate it to Prometheus metrics, which are far cheaper to store and query.

---

## Section 4: Distributed Tracing

### Core Principle
Metrics indicate that an operation is slow; logs provide sequential event details; distributed traces pinpoint exactly where the elapsed execution time was spent across service boundaries.

### Distributed Tracing Vocabulary
| Term | Definition |
| :--- | :--- |
| **Trace** | The end-to-end execution journey of a single incoming request across all systems, unified by a single globally unique `trace_id`. |
| **Span** | A single contiguous unit of work within a trace, characterized by an operation name, start timestamp, finish timestamp, attributes, and its own unique `span_id`. |
| **Parent Span** | The upstream span that initiated the current span, creating the parent-child relationship needed to reconstruct the call tree hierarchy. |
| **Trace Context** | The metadata passed across network and process boundaries (primarily via the W3C standard `traceparent` HTTP header) containing `trace_id`, `parent_id`, and trace flags. |

#### Propagation Failure Warning
If trace context is not propagated across any single network hop or service boundary, the distributed trace breaks into disconnected fragments, rendering latency attribution impossible across that hop.

### Case Study: STT Service Trace Waterfall Analysis
Analysis of a 3.2-second streaming audio session from first audio frame to first partial transcript:

```
[ws.session] ------------------------------------------------------------------ 3200 ms
  |-- [auth.verify] --- 128 ms
  |-- [audio.buffer] ------ 290 ms
  |-- [vad.filter] ---- 160 ms
  |-- [model.transcribe] --------------------------------------------- 2180 ms
  |     |-- [gpu.queue_wait] ************************************ 1660 ms
  |     `-- [gpu.infer] ---------- 450 ms
  |-- [post.punctuate] --- 150 ms
  `-- [ws.send_partial] -- 90 ms
```

#### Diagnostic Findings
- **Latency Attribution:** 76% of total transaction duration (1660 ms out of 2180 ms in `model.transcribe`) was spent idle in `gpu.queue_wait`, rather than inside speech inference execution (`gpu.infer`, 450 ms).
- **Engineering Decision:** A metrics histogram only indicates a p99 latency of 3.2 seconds. The distributed trace demonstrates that latency is solved by scaling worker capacity to relieve queue congestion, not by replacing the inference model with a smaller architecture.

### Trace Sampling Strategies
Capturing 100% of production traces incurs prohibitive network, storage, and processing costs. Sampling determines which traces are retained.

| Sampling Strategy | Mechanism | Key Advantage | Incurred Cost / Trade-off |
| :--- | :--- | :--- | :--- |
| **Head Sampling** | Sampling decision is made at the root span upon request ingress (e.g., sample 1%). | Simple implementation, predictable storage and processing overhead. | Rare edge cases and failed requests are often dropped because the decision precedes the outcome. |
| **Tail Sampling** | Spans are buffered in memory until the request completes; decision is made based on final status or duration. | Guarantees retention of slow requests, outliers, and failed transactions. | Demands significant memory buffering and complex collector infrastructure. |
| **Rate Limiting** | Enforces a hard ceiling on maximum traces recorded per second per service. | Protects budget and storage capacity from being overwhelmed during traffic spikes. | Drops traces during major outages and traffic surges, precisely when diagnostic traces are most vital. |

#### Practical Implementation Baseline
Deploy head sampling at 1% to 5% baseline traffic combined with an explicit rule to retain 100% of error states and HTTP 5xx responses. Transition to tail sampling once architectural complexity and business volume warrant dedicated collector infrastructure.

---

## Section 5: Joining the Three Pillars

Without unified linkage, monitoring data consists of three disparate repositories that cannot be synthesized into an operational narrative.

### The Four Golden Integration Rules

1. **Inject `trace_id` into Every Structured Log Line:**
   - When reviewing an error in logs, an engineer can pivot instantly into the distributed trace waterfall for that exact request.

2. **Attach Exemplars to Histogram Metrics:**
   - OpenTelemetry and Prometheus support exemplars. Clicking an outlier data point on a latency histogram opens the exact trace responsible for that latency spike.

3. **Enforce Consistent Service Naming:**
   - The service identifier (`service.name`) must match identically across Prometheus metric labels, Loki log labels, and OpenTelemetry trace resources. Inconsistent naming prevents automatic cross-navigation.

4. **Synchronize System Clocks Using NTP:**
   - Sub-second or multi-second clock drift across nodes causes events to appear out of chronological sequence, resulting in erroneous incident post-mortems and misdiagnosed root causes.

---

## Section 6: Lab 5 - Installation Day

### Context
Bill of Materials (BOM) verified; Change Request CR-01 approved; equipment is racked, cabled, powered, and verified in the containment rack.

### Pre-Installation Prerequisites
Installation cannot proceed if any prerequisite is unfulfilled.

- **Approved Documentation Required on Site:**
  - Signed Change Request (CR-01) detailing execution maintenance window and explicit rollback plan.
  - Access Request (AR-01) approved for install day specifying all authorized personnel.
  - Signed Power Verification Checklist (PWR-01) verifying capacity and phase balancing.
  - Approved Rack Layout Diagram (RACK-01) defining target U allocations.
  - Approved Cabling Schedule (CAB-01) complete with label codes and port mappings.

- **Materials Staged on Site:**
  - Physical equipment pre-sorted, unpacked, and asset-tagged.
  - Rack rail kits verified in exact quantities from the BOM.
  - Power and data patch cables pre-cut and measured to required lengths.
  - Cable labels pre-printed with standard TIA-606 identifiers.
  - Blanking panels prepared for every unoccupied rack unit.

- **Mandatory Operational Knowledge:**
  - Bottom-up installation order and mechanical stability principles.
  - Identification of heavy equipment requiring mandatory two-person lifting (> 20 kg).
  - Staggered power-on sequencing procedure.
  - All six formal acceptance criteria.
  - Clear thresholds that mandate halting work and executing rollback.

### Installation Day Timeline Sequence
```
09:00 [Sign In & Briefing]
      - Verify AR-01; sign LOG-01 visitor registry; meet facility escort.
09:30 [Mount Rails]
      - Fasten equipment rails strictly per RACK-01 diagram, moving bottom to top.
10:30 [Rack Devices]
      - Heavy hardware first; enforce mandatory two-person lift for units over 20 kg.
12:00 [Cabling]
      - Power cabling routed on left tray; data cabling routed on right tray.
      - Apply pre-printed labels to both cable ends.
14:00 [Power On]
      - Stagger boot sequence: energize 4 units per batch, spaced 30 seconds apart.
15:00 [Verification]
      - Verify Prometheus reports up == 1 across all endpoints.
      - Perform electrical checks per PWR-01; update inventory records in INV-01.
15:40 [Close Out]
      - Close out CR-01; perform tool accountability check; sign out of facility.
```

*Mandatory Safety and Governance Stop Gates:*
- Never energize electrical circuits until PWR-01 has received full sign-off.
- Never close out the maintenance window until Prometheus confirms `up == 1` for all targets.

### Why Installation Runs Bottom to Top
A sequence that appears minor has critical engineering and safety implications:
1. **Lowers Center of Gravity:** Mounting uninterruptible power supplies (UPS) and heavy storage units at the bottom minimizes rack tip-over risk during maintenance when slide rails are extended.
2. **Ergonomic Safety:** Racking top units first would force heavy equipment to be lifted past already-mounted hardware, creating serious hazard and collision risks.
3. **Preserving Reserved Slots:** Empty slots reserved for future server additions must remain unoccupied per plan; improperly filling them requires stripping and rebuilding the entire rack later.
4. **Immediate Blanking Panel Placement:** Unoccupied U positions must be sealed with blanking panels immediately to maintain cold/hot aisle airflow containment. Leaving panels for later often results in unsealed bypasses.
5. **Cabling After Hardware Mounting:** Running patch cables concurrently with equipment installation results in tangled bundles and risks snagging cables during adjacent device maintenance.

### Acceptance Criteria Before Close-Out
All six verification criteria must be formally confirmed before the change request can be closed:

| ID | Criterion | Verification Sign-off Authority |
| :--- | :--- | :--- |
| AC-1 | Every hardware device sits at its designated U position matching RACK-01 | Technical Reviewer |
| AC-2 | Every unoccupied rack unit (U) is sealed with an approved blanking panel | Safety Officer |
| AC-3 | Every cable is labelled at both ends conforming to CAB-01 specifications | Inventory Lead |
| AC-4 | Measured electrical current per PDU branch is within 80% of rated capacity | Electrical Staff |
| AC-5 | Prometheus reports metric `up == 1` across all monitored endpoints | Change Owner |
| AC-6 | Asset management database (INV-01) updated with final serials/locations and CR-01 signed closed | Change Owner |

*Integration Note:* Criterion 5 bridges morning software observability with afternoon physical infrastructure: hardware installation is incomplete until telemetry systems can verify operational state.

### ISO/IEC 27001:2022 Controls Applied on Installation Day
Physical and operational controls governing installation activities:

| Control ID | Control Name | Specific Implementation Requirement |
| :--- | :--- | :--- |
| A.8.32 | Change Management | Work strictly within approved CR-01 window; any deviation requires formal re-approval. |
| A.7.2 | Physical Entry Control | Access governed under approved AR-01; escorted throughout data centre floor. |
| A.7.8 | Equipment Siting and Protection | Mount hardware strictly per RACK-01 specifications; no ad-hoc location changes. |
| A.7.11 | Supporting Utilities | Measure real-time current draw post power-on and record on PWR-01. |
| A.7.12 | Cabling Security | Route power and signal cables on separate containment trays; label both ends. |
| A.5.9 | Inventory of Assets | Update device physical location, serial numbers, and rack elevation in INV-01 on install day. |

---

## Assignments and Next Week

### Group Deliverables (Due in 5 Days)
- High-resolution photographic documentation of the completed rack (front and rear elevations).
- Fully updated INV-01 asset inventory containing final hardware locations.
- Completed PWR-01 form documenting measured electrical loads under active power.
- Closed CR-01 document containing retrospective summary of deviations or incidents.

### Individual Deliverables (Before Next Session)
- Read *Observability Engineering* (Majors, Fong-Jones, & Miranda), Chapters 6 and 7 (Structured Events).
- Complete Pre-Class Quiz 5 on LMS.
- Instrument the sample application with at least three structured log events including `trace_id`.
- Submit waterfall trace screenshot demonstrating at least three nested levels of spans.

### Preparation for Week 6: Alerting and On-Call
- Integrate Alertmanager into the Week 4 Prometheus/Grafana monitoring stack.
- Draft initial alert definitions for service SLIs.
- Formulate criteria distinguishing actionable paging alerts from informational tickets.
- *Opening Question for Week 6:* "An alert fires at 2:00 AM and requires no immediate operational action - should it be deleted, or kept just in case?"

---

## References and Standards

### Lecture References
- Majors, C., Fong-Jones, L., & Miranda, G. (2022). *Observability Engineering*. O'Reilly Media. Chapters 4–8.
- OpenTelemetry Documentation: Tracing specifications, context propagation, and sampling models.
- W3C Recommendation: *Trace Context - W3C Recommendation* (traceparent and tracestate headers).
- Grafana Labs: *Loki Best Practices: Label Design and Scalability*.
- Sigelman, B. H., et al. (2010). *Dapper, a Large-Scale Distributed Systems Tracing Infrastructure*. Google Technical Report.

### Field Lab References
- ISO/IEC 27001:2022 Information Security Management System - Annex A Controls:
  - A.5.9 (Inventory of assets)
  - A.7.2 (Physical entry)
  - A.7.8 (Equipment siting and protection)
  - A.7.11 (Supporting utilities)
  - A.7.12 (Cabling security)
  - A.8.32 (Change management)
- Manufacturer Technical Guides: Server chassis, rail mounting, and containment rack specifications.
- Course Operations Pack: CR-01, AR-01, PWR-01, RACK-01, CAB-01, INV-01 forms.
- Approved Group Bill of Materials (BOM) and capacity calculations from Week 4.

---

## Summary: Today in Three Sentences
1. Metrics announce that a problem exists, logs explain what happened, and distributed traces reveal where time was spent - none can substitute for another.
2. Loki label design enforces the exact same rules as Prometheus: high-cardinality values (`session_id`, `trace_id`) belong in the log payload, never in index labels.
3. Hardware installation is not complete until observability systems actively monitor the newly racked equipment (`up == 1`).
