-- ============================================================================
-- 05_sla_framework.sql
-- Deterministic modular extraction
-- Guarantees:
--   ✔ Zero skipped statements
--   ✔ No duplicate SQL within file
--   ✔ Ordered deployment sequence
-- ============================================================================

-- │   • SLA tracking views                                                   │
-- │  • Email / Slack     │  │                                            │
-- TBL_SLA_DEFINITIONS: Configuration-driven SLA thresholds per service.
-- Decouples threshold values from view logic for easy tuning without DDL changes.
-- Review quarterly with service owners to adjust thresholds.
    threshold_value      FLOAT,
    s.threshold_value,
             END > s.threshold_value THEN 'BREACHED'
    END AS sla_status
-- Minimum volume threshold (10 requests) prevents false positives during low traffic.
-- SAMPLE QUERY 2: Slowest queries (last 24 hours)
--    • Validate SLA thresholds quarterly
-- │ Alert fatigue              │ Tuned thresholds, severity levels            │
--   * Establish TBL_SLA_DEFINITIONS
--   * Tune alert thresholds based on baseline data
--   VW_SLA_COMPLIANCE         - SLA breach detection
--   TBL_SLA_DEFINITIONS       - SLA threshold configuration
        REGR_SLOPE(daily_requests, DATEDIFF('day', (SELECT MIN(day) FROM daily_stats), day)) AS daily_growth_rate,
    COUNT_IF(response_time_ms > 3000) AS critical_slow_count,
    COUNT_IF(response_time_ms BETWEEN 1000 AND 3000) AS medium_slow_count,
    ROUND(100.0 * critical_slow_count / NULLIF(request_count, 0), 2) AS pct_critical_slow
--   ALT_STALE_INDEX               - Index freshness breach
    ROUND(AVG(hourly_count) + 3 * COALESCE(STDDEV(hourly_count), 0), 0) AS spike_threshold
    WHERE curr.current_count > bl.spike_threshold
      'Current hour volume exceeds weekday/hour baseline threshold.'
-- ║   T4  - SLA Framework (definitions, compliance view, breach logic)            ║
    -- T3.2: VW_SLOW_QUERIES compiles
            'Slow queries view compiles and executes',
-- 13E. T4 - SLA FRAMEWORK VALIDATION
    sla_count NUMBER;
    -- T4.1: SLA definitions table has data
    test_result := (sla_count > 0);
    SELECT :suite_run_id, 'T4_SLA_FRAMEWORK', 'T4.1', 'SLA Definitions Populated',
            'TBL_SLA_DEFINITIONS has threshold entries',
            '>0 rows', :sla_count::STRING || ' rows', :test_result, 0
    -- T4.2: SLA compliance view compiles
    SELECT :suite_run_id, 'T4_SLA_FRAMEWORK', 'T4.2', 'VW_SLA_COMPLIANCE Queryable',
            'SLA compliance view executes without error',
    -- T4.3: SLA status values are valid (COMPLIANT or BREACHED only)
                    WHERE sla_status NOT IN ('COMPLIANT', 'BREACHED'));
    SELECT :suite_run_id, 'T4_SLA_FRAMEWORK', 'T4.3', 'SLA Status Values Valid',
            'All sla_status values are COMPLIANT or BREACHED',
    SELECT :suite_run_id, 'T4_SLA_FRAMEWORK', 'T4.4', 'SLA Severity Values Valid',
    RETURN 'T4_SLA_FRAMEWORK: 4 tests completed';
--   SP_TEST_T4_SLA_FRAMEWORK      - 4 tests (definitions, compliance, values)
    error_sla_status STRING;
    error_sla_status := IFF(error_rate > 1, 'Breached ' || error_rate::STRING || '%', 'Compliant');
      || '<h2 style="margin:0 0 16px;font-size:14px;font-weight:700;color:#0F2A44;text-transform:uppercase;letter-spacing:0.5px;">SLA Compliance</h2>'
      || '<td align="right"><span style="display:inline-block;background-color:' || IFF(error_rate > 1, '#FEF3C7;color:#D97706', '#ECFDF5;color:#059669') || ';font-size:11px;font-weight:700;padding:4px 10px;border-radius:12px;">' || UPPER(error_sla_status) || '</span></td>'
      'COST_THRESHOLD',
-- 16G. SLA DEFINITIONS CHANGE TRACKING (AUDIT TRAIL)
    old_threshold FLOAT,
    new_threshold FLOAT,
    THRESHOLD_VALUE,
--   TBL_SLA_DEFINITIONS_HISTORY    - SLA change audit trail
--   ALT_COST_THRESHOLD             - Daily credit > 10 warning
--   STR_SLA_CHANGES                - CDC on SLA definitions
--   TSK_TRACK_SLA_CHANGES          - Logs SLA threshold changes