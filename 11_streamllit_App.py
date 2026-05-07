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
