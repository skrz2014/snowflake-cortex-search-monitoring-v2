# ❄️ Snowflake Cortex Search Observability Platform

> **65 automated tests. CXO-ready HTML alerts. Real-time anomaly detection. Built entirely in Snowflake SQL — no external tools.**


---

## 🔍 The Problem

Most organizations deploying AI-powered search have **zero visibility** into what's happening under the hood.

Users are searching. Results are returning. Credits are burning. But nobody can answer:

- Which queries are failing silently?
- Who is consuming the most AI credits?
- Are we meeting our latency SLAs?
- Is someone scraping data through the search API?

This platform transforms **Snowflake Cortex Search** from opaque AI infrastructure into a **fully governed, observable capability** — with executive HTML reports, automated anomaly detection, and a 65-test validation suite.

---

## 🚀 What This Platform Delivers

| Capability | Details |
|---|---|
| 📊 Monitoring Views | 23+ views parsing real-time telemetry |
| 🚨 HTML Alerts | 5 executive-grade alerts with color-coded severity |
| 💰 Cost Attribution | Actual Snowflake billing data — not estimates |
| 🛡️ PII Protection | Dynamic masking across SSN, credit cards, emails, credentials |
| ✅ Test Suite | 65 automated tests (100% pass rate) |
| 📈 Anomaly Detection | Contradiction-aware CXO executive reports |
| ⏱️ Deployment Time | Under 4 hours |
| 💳 Monthly Cost | Under 50 credits/month |

---

## 🏗️ Architecture

```
AI_OBSERVABILITY_EVENTS (Snowflake Native Telemetry)
         │
         ▼
VW_SEARCH_REQUESTS  ◄── Single Source of Truth (7-day rolling window)
         │
    ┌────┴─────────────────────────────────┐
    │                                      │
    ▼                                      ▼
Monitoring Views (23+)              SLA Framework
    │                                      │
    ├── VW_SLOW_QUERIES                    ├── TBL_SLA_DEFINITIONS
    ├── VW_FAILED_REQUESTS                 └── VW_SLA_COMPLIANCE
    ├── VW_TOP_USERS                              │
    ├── VW_SERVICE_METRICS                        ▼
    └── VW_DAILY_TRENDS                   HTML Alerts (5)
                                                  │
Cost Attribution ◄──────────────────────── CXO Report
    │                                      (Anomaly Detection)
    ├── VW_ACTUAL_SERVICE_COSTS
    ├── VW_COST_BY_USER
    └── VW_CHARGEBACK_BY_ROLE

Governance Layer
    ├── PII Masking Policy
    ├── RBAC (3-tier)
    └── 65-Test Validation Suite
```

---

## 📋 Prerequisites

| Requirement | Details |
|---|---|
| Snowflake Edition | Enterprise or Business Critical |
| Role Required | `ACCOUNTADMIN` for initial setup |
| Warehouse Size | `XSMALL` is sufficient |
| Cortex Search | At least one service with `REQUEST_LOGGING = TRUE` |
| Estimated Cost | ~50 credits/month depending on query volume |

---

## 📁 Repository Structure

| File | Purpose |
|---|---|
| `01_rbac_infrastructure.sql` | Databases, schemas, roles, warehouses |
| `02_enable_request_logging.sql` | Activates the telemetry pipeline |
| `03_vw_search_requests.sql` | Foundation view — single source of truth |
| `04_monitoring_views.sql` | 23+ operational monitoring views |
| `05_sla_framework.sql` | Configuration-driven SLA thresholds |
| `06_cost_attribution.sql` | Cost allocation using actual billing data |
| `07_pii_masking.sql` | PII detection and dynamic masking policies |
| `08_html_alerts.sql` | 5 executive HTML alerting workflows |
| `09_test_suite.sql` | 65-test validation suite |
| `10_cxo_report.sql` | CXO dashboard with anomaly detection |
| `11_streamli_App.py` | Streamlit App for dashboard |
| `full_implementation.sql` | Single-file end-to-end deployment |
| `deploy.sh` | Automated deployment script |
| `streamlit_dashboard.py` | Interactive Streamlit observability dashboard |

---

## ⚡ Quick Start

### Option 1 — Automated Deployment

```bash
git clone https://github.com/skrz2014/snowflake-cortex-search-monitoring-v2.git
cd snowflake-cortex-search-monitoring-v2
chmod +x deploy.sh && ./deploy.sh
```

### Option 2 — Manual (Snowsight)

Run files `01_` through `10_` sequentially in Snowsight.

### Option 3 — Single File

Use `full_implementation.sql` for a complete one-shot deployment.

---

## 🔧 Step-by-Step Implementation

### Step 1 — Enable Request Logging

One configuration change activates the entire telemetry pipeline:

```sql
ALTER CORTEX SEARCH SERVICE your_database.your_schema.your_service
  SET REQUEST_LOGGING = TRUE;
```

### Step 2 — Deploy & Validate

```sql
-- Run the full test suite after deployment
CALL PRD_CORTEX_OBSERVABILITY.MONITORING.SP_RUN_FULL_TEST_SUITE();
-- Expected: 65/65 PASS ✓

-- Send your first CXO executive report
CALL PRD_CORTEX_OBSERVABILITY.MONITORING.SP_SEND_CXO_REPORT('you@yourcompany.com');
```

---

## 🔐 Security & Governance

### Role Hierarchy (Least Privilege)

```
CORTEX_OBS_ADMIN        ← Manage policies & config
      │
CORTEX_OBS_ANALYST      ← Full data access
      │
CORTEX_OBS_READONLY     ← Masked query text (PII protection)
```

### PII Detection Patterns

| Pattern | Redaction |
|---|---|
| SSN (`123-45-6789`) | `[REDACTED-SSN]` |
| Credit Card (13–16 digits) | `[REDACTED-CC]` |
| Email addresses | `[REDACTED-EMAIL]` |
| Passwords / API keys | `[REDACTED-CRED]` |

> ⚠️ **Security Note:** Redaction is applied **before** truncation to prevent partial data leakage.

---

## 🚨 Alerts

| Alert | Schedule | Trigger Condition |
|---|---|---|
| `ALERT_PIPELINE_HEALTH` | Every 5 min | Zero events in last 10 minutes |
| `ALERT_LATENCY_SLA` | Every 5 min | P95 latency SLA breached |
| `ALERT_ERROR_SPIKE` | Every 5 min | Error rate exceeds 10% |
| `ALERT_VOLUME_ANOMALY` | Every 15 min | Traffic > 3σ above 7-day baseline |
| `ALERT_ABUSE_DETECTION` | Every 10 min | Single user > 500 requests in 10 min |

All alerts deliver **CXO-grade HTML emails** with color-coded severity and actionable runbooks.

---

## 📊 SLA Configuration

Thresholds are configuration-driven — no DDL changes required to update them:

```sql
-- Tighten P95 SLA from 1500ms to 1000ms — one UPDATE, no view recreation
UPDATE PRD_CORTEX_OBSERVABILITY.MONITORING.TBL_SLA_DEFINITIONS
  SET threshold_value = 1000
  WHERE metric = 'p95_latency'
    AND severity = 'HIGH';
```

Default thresholds:

| Metric | Threshold | Severity |
|---|---|---|
| P95 Latency | 1,500 ms | HIGH |
| P99 Latency | 3,000 ms | CRITICAL |
| Error Rate | 5% | HIGH |
| Error Rate | 15% | CRITICAL |
| Avg Latency | 800 ms | MEDIUM |

---

## 💰 Cost Attribution

Uses **actual Snowflake billing data** from `CORTEX_SEARCH_DAILY_USAGE_HISTORY` — not estimates.

```sql
-- View cost allocated per user based on token share
SELECT * FROM PRD_CORTEX_OBSERVABILITY.MONITORING.VW_COST_BY_USER
ORDER BY allocated_credits DESC;

-- Role-based chargeback reporting
SELECT * FROM PRD_CORTEX_OBSERVABILITY.MONITORING.VW_CHARGEBACK_BY_ROLE;
```

---

## 🧪 Test Suite

65 automated tests across 8 categories:

| Category | Tests | Coverage |
|---|---|---|
| Infrastructure | T1-xx | Database, schemas, warehouse |
| Event Ingestion | T2-xx | `AI_OBSERVABILITY_EVENTS` accessibility |
| View Correctness | T3-xx | Column presence, NULL handling |
| SLA Logic | T4-xx | Threshold configuration |
| Cost Attribution | T5-xx | Billing view accessibility |
| Security / Masking | T6-xx | SSN, email, credential redaction |
| Retention & Performance | T7–T9 | Pipeline integrity, benchmarks |
| End-to-End | T10–T12 | Alert triggers, integration |

```sql
CALL PRD_CORTEX_OBSERVABILITY.MONITORING.SP_RUN_FULL_TEST_SUITE();
```

---

## ⚡ Performance Optimization

| Technique | Impact |
|---|---|
| Materialized Views for rollups | 10–50x faster dashboard queries |
| Clustering on `(metric_date, service_name)` | Reduced partition scans |
| 3-minute buffer view for stable reads | Prevents partial event reads |
| Direct event query for abuse detection | Up to 168x scan reduction |
| Resource Monitor (50 credit cap) | Cost safety net |
| Query Acceleration (scale factor 4) | Handles spiky BI workloads |

---

## 🗺️ Roadmap

| Timeline | Enhancement |
|---|---|
| Week 1–2 | Enable on production Cortex Search services |
| Month 1 | Dynamic Tables for automated aggregations |
| Month 2 | ML-powered anomaly detection via Snowflake ML functions |
| Q2 | Cross-account observability federation |
| Future | Predictive cost and usage analytics |
| Future | Automated remediation workflows for SLA incidents |
| Future | Governance telemetry integration with compliance reporting |

---

## 📊 Streamlit Dashboard

A fully interactive observability dashboard built with **Streamlit in Snowflake** — no external hosting required.

### Dashboard Tabs

| Tab | Contents |
|---|---|
| 📊 **Overview** | Platform health KPIs, service registry, anomaly detection |
| ⚡ **Latency** | Hourly P95 line chart, latency details table, SLA compliance |
| 🚨 **Errors & Abuse** | Abuse detection, user frustration signals, query quality ratings |
| 💰 **Cost Attribution** | Cost by user & service, role distribution bar chart, daily credit trends |
| 📈 **Trends** | Weekly active users, WoW growth %, 30-day volume forecast, tenant metrics |
| 🛡️ **Governance** | PII audit, schema drift detection, data quality, index freshness |

### Deploy the Dashboard

**Step 1 — Upload to Snowflake**

```sql
-- In Snowsight: Streamlit → + Streamlit App
-- Select warehouse: CORTEX_OBS_WH
-- Paste contents of streamlit_dashboard.py
```

**Step 2 — Grant access**

```sql
GRANT USAGE ON INTEGRATION CORTEX_OBS_EMAIL_INTEGRATION
  TO ROLE CORTEX_OBS_ANALYST;
```

**Step 3 — Run**

Open the app in Snowsight. The dashboard auto-refreshes on every page load.

### Dashboard Code

```python
import streamlit as st
import pandas as pd
from snowflake.snowpark.context import get_active_session

st.set_page_config(page_title="Cortex Search Observability", layout="wide")

session = get_active_session()

def run_query(sql):
    return session.sql(sql).to_pandas()

st.title("🔍 Cortex Search Observability Dashboard")

tab1, tab2, tab3, tab4, tab5, tab6 = st.tabs([
    "📊 Overview", "⚡ Latency", "🚨 Errors & Abuse",
    "💰 Cost Attribution", "📈 Trends", "🛡️ Governance"
])

with tab1:
    st.header("Platform Health")
    try:
        kpis = run_query("SELECT metric_name, metric_value, description FROM PRD_CORTEX_OBSERVABILITY.MONITORING.VW_EXEC_DASHBOARD")
        cols = st.columns(len(kpis))
        for i, row in kpis.iterrows():
            with cols[i]:
                st.metric(label=row["METRIC_NAME"].replace("_", " ").title(), value=row["METRIC_VALUE"])
                st.caption(row["DESCRIPTION"])
    except Exception as e:
        st.warning(f"Could not load KPIs: {e}")

    st.subheader("Service Registry")
    try:
        services = run_query("SELECT service_name, database_name, schema_name, total_requests, unique_users, avg_latency_ms, service_status FROM PRD_CORTEX_OBSERVABILITY.MONITORING.VW_SERVICE_REGISTRY")
        st.dataframe(services, use_container_width=True)
    except Exception as e:
        st.warning(f"Could not load services: {e}")

    st.subheader("Anomaly Detection")
    try:
        anomalies = run_query("SELECT * FROM PRD_CORTEX_OBSERVABILITY.MONITORING.VW_ANOMALY_DETECTION")
        st.dataframe(anomalies, use_container_width=True)
    except Exception as e:
        st.info("No anomaly data available yet.")

with tab2:
    st.header("Latency Analysis")
    try:
        latency = run_query("""
            SELECT service_name, hour_bucket, request_count, p95_ms, max_latency_ms, critical_slow_count
            FROM PRD_CORTEX_OBSERVABILITY.MONITORING.VW_LATENCY_ANALYSIS
            ORDER BY hour_bucket DESC LIMIT 168
        """)
        st.subheader("Hourly P95 Latency")
        chart_data = latency.pivot_table(index="HOUR_BUCKET", columns="SERVICE_NAME", values="P95_MS").reset_index()
        chart_data = chart_data.set_index("HOUR_BUCKET")
        st.line_chart(chart_data)

        st.subheader("Latency Details")
        st.dataframe(latency[["HOUR_BUCKET", "SERVICE_NAME", "REQUEST_COUNT", "P95_MS", "MAX_LATENCY_MS", "CRITICAL_SLOW_COUNT"]].head(24), use_container_width=True)
    except Exception as e:
        st.warning(f"Could not load latency data: {e}")

    st.subheader("SLA Compliance")
    try:
        sla = run_query("SELECT * FROM PRD_CORTEX_OBSERVABILITY.MONITORING.VW_SLA_COMPLIANCE LIMIT 50")
        st.dataframe(sla, use_container_width=True)
    except Exception as e:
        st.info("SLA compliance view not available.")

with tab3:
    st.header("Error & Abuse Detection")
    col1, col2 = st.columns(2)
    with col1:
        st.subheader("Abuse Detection")
        try:
            abuse = run_query("SELECT * FROM PRD_CORTEX_OBSERVABILITY.MONITORING.VW_ABUSE_DETECTION ORDER BY peak_rpm DESC LIMIT 20")
            st.dataframe(abuse, use_container_width=True)
        except Exception as e:
            st.info("No abuse data available.")

    with col2:
        st.subheader("User Frustration Signals")
        try:
            frustration = run_query("SELECT * FROM PRD_CORTEX_OBSERVABILITY.MONITORING.VW_USER_FRUSTRATION_SIGNALS LIMIT 20")
            st.dataframe(frustration, use_container_width=True)
        except Exception as e:
            st.info("No frustration signals detected.")

    st.subheader("Query Quality")
    try:
        quality = run_query("SELECT query_text, total_requests, zero_result_pct, avg_latency_ms, quality_rating FROM PRD_CORTEX_OBSERVABILITY.MONITORING.VW_QUERY_QUALITY LIMIT 30")
        st.dataframe(quality, use_container_width=True)
    except Exception as e:
        st.info("Query quality data not available.")

with tab4:
    st.header("Cost Attribution")
    try:
        costs = run_query("""
            SELECT service_name, user_name, role_name,
                   SUM(attributed_cost_usd) AS total_cost_usd,
                   SUM(attributed_credits) AS total_credits,
                   SUM(request_count) AS total_requests
            FROM PRD_CORTEX_OBSERVABILITY.MONITORING.VW_TRUE_COST_ATTRIBUTION
            GROUP BY service_name, user_name, role_name
            ORDER BY total_cost_usd DESC
            LIMIT 50
        """)
        st.subheader("Cost by User & Service")
        st.dataframe(costs, use_container_width=True)

        st.subheader("Cost Distribution by Role")
        role_costs = costs.groupby("ROLE_NAME")["TOTAL_COST_USD"].sum().reset_index()
        st.bar_chart(role_costs, x="ROLE_NAME", y="TOTAL_COST_USD")
    except Exception as e:
        st.warning(f"Could not load cost data: {e}")

    st.subheader("Daily Observability Costs")
    try:
        daily_costs = run_query("SELECT * FROM PRD_CORTEX_OBSERVABILITY.MONITORING.VW_DAILY_OBSERVABILITY_COSTS LIMIT 30")
        st.line_chart(daily_costs, x="USAGE_DATE", y="TOTAL_CREDITS")
    except Exception as e:
        st.info("Daily cost data not available.")

with tab5:
    st.header("Adoption & Volume Trends")
    try:
        adoption = run_query("SELECT * FROM PRD_CORTEX_OBSERVABILITY.MONITORING.VW_ADOPTION_TREND")
        st.subheader("Weekly Active Users & Requests")
        st.line_chart(adoption, x="WEEK_START", y=["WEEKLY_REQUESTS", "WEEKLY_ACTIVE_USERS"])

        st.subheader("Week-over-Week Growth")
        st.dataframe(adoption[["WEEK_START", "WEEKLY_REQUESTS", "WEEKLY_ACTIVE_USERS", "WOW_GROWTH_PCT"]], use_container_width=True)
    except Exception as e:
        st.warning(f"Could not load adoption data: {e}")

    st.subheader("Volume Forecast (Next 30 Days)")
    try:
        forecast = run_query("SELECT * FROM PRD_CORTEX_OBSERVABILITY.MONITORING.VW_VOLUME_FORECAST")
        st.line_chart(forecast, x="FORECAST_DATE", y="PREDICTED_DAILY_REQUESTS")
    except Exception as e:
        st.info("Volume forecast not available.")

    st.subheader("Tenant Metrics")
    try:
        tenants = run_query("SELECT * FROM PRD_CORTEX_OBSERVABILITY.MONITORING.VW_TENANT_METRICS ORDER BY usage_date DESC LIMIT 50")
        st.dataframe(tenants, use_container_width=True)
    except Exception as e:
        st.info("Tenant metrics not available.")

with tab6:
    st.header("Data Governance & Quality")
    col1, col2 = st.columns(2)
    with col1:
        st.subheader("PII Audit")
        try:
            pii = run_query("SELECT * FROM PRD_CORTEX_OBSERVABILITY.GOVERNANCE.VW_PII_AUDIT LIMIT 20")
            st.dataframe(pii, use_container_width=True)
        except Exception as e:
            st.info("No PII detections found.")

    with col2:
        st.subheader("Schema Drift Detection")
        try:
            drift = run_query("SELECT * FROM PRD_CORTEX_OBSERVABILITY.MONITORING.VW_SCHEMA_DRIFT_DETECTION")
            st.dataframe(drift, use_container_width=True)
        except Exception as e:
            st.info("Schema drift data not available.")

    st.subheader("Data Quality")
    try:
        dq = run_query("SELECT * FROM PRD_CORTEX_OBSERVABILITY.MONITORING.VW_DATA_QUALITY ORDER BY hour_bucket DESC LIMIT 24")
        st.dataframe(dq, use_container_width=True)
    except Exception as e:
        st.info("Data quality metrics not available.")

    st.subheader("Index Freshness")
    try:
        freshness = run_query("SELECT * FROM PRD_CORTEX_OBSERVABILITY.MONITORING.VW_FRESHNESS_STATUS")
        st.dataframe(freshness, use_container_width=True)
    except Exception as e:
        st.info("Freshness data not available.")

st.divider()
st.caption("Cortex Search Observability Dashboard | PRD_CORTEX_OBSERVABILITY | Auto-refreshes on page load")
```

> 💡 **Tip:** The full dashboard file is available as [`streamlit_dashboard.py`](./streamlit_dashboard.py) in the repository root.

---

## 📺 Demo

Watch the full walkthrough: [YouTube Demo](https://youtu.be/TZlwoGRpYUc)

Read the full article: [Medium — I Turned Snowflake Cortex Search from a Black Box into a Fully Governed AI Observability Platform](https://medium.com/@satish-kumar)

---

## 🤝 Contributing

Contributions are welcome! Please open an issue or submit a pull request.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Commit your changes (`git commit -m 'Add your feature'`)
4. Push to the branch (`git push origin feature/your-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](./LICENSE) file for details.

---

## ⚠️ Disclaimer

This project is based on personal hands-on experience and is provided for educational purposes only. All architectural recommendations, SQL examples, and cost estimates should be validated in your own Snowflake environment before production use. Snowflake features, pricing, and APIs may change — always refer to the [official documentation](https://docs.snowflake.com) for the latest guidance.

---

<p align="center">
  Built with ❄️ by <a href="https://github.com/skrz2014">Satish Kumar</a> &nbsp;|&nbsp;
  <a href="https://youtu.be/TZlwoGRpYUc">Demo</a> &nbsp;|&nbsp;
  <a href="https://medium.com/@satish-kumar">Article</a>
</p>
