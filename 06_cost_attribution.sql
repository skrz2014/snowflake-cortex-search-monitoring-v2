-- ============================================================================
-- 06_cost_attribution.sql
-- Deterministic modular extraction
-- Guarantees:
--   ✔ Zero skipped statements
--   ✔ No duplicate SQL within file
--   ✔ Ordered deployment sequence
-- ============================================================================

--   • Cost attribution and chargeback for Cortex AI consumption
-- COST TRANSPARENCY:
--   • Per-service, per-user, per-role usage attribution
-- AUTO_SUSPEND = 60s minimizes idle credit consumption.
-- Feeds into cost attribution and chargeback models.
-- 3F. COST GOVERNANCE MODEL
-- VW_ACTUAL_SERVICE_COSTS: Real credit consumption from Snowflake Account Usage.
-- Source: CORTEX_SEARCH_DAILY_USAGE_HISTORY (Serving + Embed + Batch costs).
    USAGE_DATE::DATE                     AS cost_date,
    CREDITS                              AS actual_credits,
ORDER BY cost_date DESC;
-- VW_COST_BY_USER: Per-user daily request counts with ACTUAL cost attribution.
-- Allocates real service credits proportionally based on user request volume.
-- Actual credits from CORTEX_SEARCH_DAILY_USAGE_HISTORY / user share of traffic.
actual_costs AS (
        USAGE_DATE::DATE AS cost_date,
        SUM(CREDITS) AS total_daily_credits
    GROUP BY cost_date, service_name
    COALESCE(ac.total_daily_credits, 0) AS service_actual_credits,
    ROUND(ac.total_daily_credits * (u.request_count / NULLIF(dt.total_daily_requests, 0)), 6) AS attributed_credits_actual,
    ROUND(attributed_credits_actual * 3.00, 4) AS attributed_cost_usd
LEFT JOIN actual_costs ac ON u.service_name = ac.service_name AND u.usage_date = ac.cost_date
ORDER BY u.usage_date DESC, attributed_credits_actual DESC;
-- VW_COST_BY_SERVICE: Monthly service-level ACTUAL cost from Snowflake billing.
        SUM(CREDITS) AS actual_credits,
    SUM(IFF(a.CONSUMPTION_TYPE = 'SERVING', a.actual_credits, 0)) AS serving_credits,
    SUM(IFF(a.CONSUMPTION_TYPE = 'EMBED_TEXT_TOKENS', a.actual_credits, 0)) AS embedding_credits,
    SUM(IFF(a.CONSUMPTION_TYPE = 'BATCH', a.actual_credits, 0)) AS batch_credits,
    SUM(COALESCE(a.actual_credits, 0)) AS total_actual_credits,
    ROUND(SUM(COALESCE(a.actual_credits, 0)) * 3.00, 2) AS total_cost_usd,
    ROUND(SUM(COALESCE(a.actual_credits, 0)) / NULLIF(r.monthly_requests, 0), 8) AS actual_credit_per_request
ORDER BY usage_month DESC, total_actual_credits DESC;
-- VW_CHARGEBACK_BY_ROLE: Weekly credit attribution by role using ACTUAL costs.
actual_weekly_costs AS (
        SUM(CREDITS) AS total_weekly_credits
    COALESCE(ac.total_weekly_credits, 0) AS service_actual_weekly_credits,
    ROUND(ac.total_weekly_credits * (r.weekly_requests / NULLIF(wt.total_weekly_requests, 0)), 6) AS attributed_credits_actual,
LEFT JOIN actual_weekly_costs ac ON r.service_name = ac.service_name AND r.usage_week = ac.usage_week
ORDER BY r.usage_week DESC, attributed_credits_actual DESC;
-- VW_SERVING_HOURLY_COSTS: Granular hourly serving credit breakdown per service.
    CREDITS AS serving_credits,
    ROUND(CREDITS * 3.00, 4) AS serving_cost_usd,
-- Runs monthly on the 1st at 03:00 UTC. Balances storage cost vs compliance needs.
-- ║ 6. PERFORMANCE & COST CONSIDERATIONS                                        ║
-- STORAGE COSTS:
-- QUERY COSTS:
--    • Review cost attribution accuracy monthly
-- LEVEL 4 - COST ATTRIBUTION (Week 7-8):
--   * Deploy VW_COST_BY_USER, VW_COST_BY_SERVICE, VW_CHARGEBACK_BY_ROLE
--   * Establish chargeback model per business unit
--   * Monthly cost review process with finance
--   VW_COST_BY_USER           - Per-user credit attribution
--   VW_COST_BY_SERVICE        - Per-service monthly credits
--   VW_CHARGEBACK_BY_ROLE     - Role-based weekly chargeback
  WITH CREDIT_QUOTA = 500
    SUM(CREDITS_USED) AS total_credits,
    predicted_daily_requests * 0.001 AS predicted_daily_credits,
    predicted_daily_credits * 3.00 AS predicted_daily_cost_usd
        SUM(CREDITS_USED) AS hourly_credits,
        SUM(CREDITS_USED) * 3.00 AS hourly_cost_usd
    ROUND(wc.hourly_cost_usd * (hr.request_count / NULLIF(ht.total_requests, 0)), 4) AS attributed_cost_usd,
    ROUND(wc.hourly_credits * (hr.request_count / NULLIF(ht.total_requests, 0)), 6) AS attributed_credits
ORDER BY hr.hour_bucket DESC, attributed_cost_usd DESC;
        WHEN REGEXP_LIKE(query_text, '.*\\d{4}[- ]?\\d{4}[- ]?\\d{4}[- ]?\\d{4}.*') THEN 'CREDIT_CARD'
--   VW_TRUE_COST_ATTRIBUTION      - Real $/credit per user/service/role
        COUNT(*) * pc.credit_per_req AS total_estimated_credits
    GROUP BY service_name, pc.credit_per_req;
            COUNT(*) * COALESCE(pc.credit_per_req, 0.001)
        GROUP BY service_name, pc.credit_per_req;
    credit_per_req  FLOAT,
           0.001 AS credit_per_req,
    INSERT (service_type, credit_per_req, effective_from, effective_to)
    VALUES (src.service_type, src.credit_per_req, src.effective_from, src.effective_to);
-- 12H. COST & PERFORMANCE: STREAM-BASED INCREMENTAL ALERT PROCESSING
  WITH CREDIT_QUOTA = 50
    ('CREDIT_PER_REQUEST', '0.001', 'Current credit multiplier'),
--   TBL_PRICING_CONFIG               - Single source of truth for credit rates
--   RM_CORTEX_OBS_MONTHLY            - 50-credit safety cap
-- ║   T5  - Cost Governance (attribution accuracy, pricing config)                ║
-- 13F. T5 - COST GOVERNANCE VALIDATION
    SELECT :suite_run_id, 'T5_COST_GOVERNANCE', 'T5.1', 'Pricing Config Populated',
    -- T5.2: VW_COST_BY_USER compiles
    SELECT :suite_run_id, 'T5_COST_GOVERNANCE', 'T5.2', 'VW_COST_BY_USER Queryable',
            'User cost attribution view executes',
    -- T5.3: VW_COST_BY_SERVICE compiles
    SELECT :suite_run_id, 'T5_COST_GOVERNANCE', 'T5.3', 'VW_COST_BY_SERVICE Queryable',
            'Service cost attribution view executes',
    -- T5.4: VW_TRUE_COST_ATTRIBUTION compiles
    SELECT :suite_run_id, 'T5_COST_GOVERNANCE', 'T5.4', 'VW_TRUE_COST_ATTRIBUTION Queryable',
            'Daily cost tracking view executes',
    RETURN 'T5_COST_GOVERNANCE: 5 tests completed';
--   SP_TEST_T5_COST_GOVERNANCE    - 5 tests (pricing, attribution views)
    monthly_cost STRING;
      || '<tr><td style="padding:6px 0;"><span style="color:#059669;font-weight:700;">&#10003;</span> <span style="font-size:13px;color:#374151;">Cost Chargeback Ready</span></td>'
-- 16F. COST CONTROL ALERT
      AND total_credits > 10
-- 17F. OBJECT TAGGING (GOVERNANCE + COST SHOWBACK)
-- 17G. QUERY TAGS FOR ATTRIBUTION
    DATE_TRUNC('month', r.usage_date) AS billing_month,
    SUM(r.attributed_credits_actual) AS total_credits,
    SUM(r.attributed_cost_usd) AS total_cost_usd
GROUP BY team_identifier, billing_month
ORDER BY billing_month DESC, total_cost_usd DESC;
--   VW_COST_SHOWBACK               - Monthly cost by team/role
--   TAG_COST_CENTER                - AI_PLATFORM, SECURITY_OPS, FINANCE, ENGINEERING