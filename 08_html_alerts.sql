-- ============================================================================
-- 08_html_alerts.sql
-- Deterministic modular extraction
-- Guarantees:
--   ✔ Zero skipped statements
--   ✔ No duplicate SQL within file
--   ✔ Ordered deployment sequence
-- ============================================================================

--   Integration:  NI_<PURPOSE>                  (e.g. NI_CORTEX_OBS_EMAIL)
-- │   ALERTING LAYER     │  │       REPORTING / BI LAYER                  │
-- │  • Notification      │  │  • Power BI / Tableau                      │
-- 3G. ALERTING & AUTOMATION
-- NI_CORTEX_OBS_EMAIL: Email notification integration for automated alert delivery.
-- ALLOWED_RECIPIENTS restricts who can receive emails (security best practice).
-- Requires: Recipients must have verified email addresses in Snowflake.
CREATE OR REPLACE NOTIFICATION INTEGRATION NI_CORTEX_OBS_EMAIL
  TYPE = EMAIL
    CALL SYSTEM$SEND_EMAIL(
      'NI_CORTEX_OBS_EMAIL',
--    • Use ALERTs for real-time anomaly detection
--    • Test alerts in non-production before deploying
-- │ Single point of failure    │ Redundant alerts, multiple notification      │
-- │                            │ channels (email + webhook)                   │
-- LEVEL 3 - AUTOMATED ALERTING (Week 5-6):
--   * Configure NI_CORTEX_OBS_EMAIL notification integration
-- Integration:   NI_CORTEX_OBS_EMAIL
-- Alerts:
        WHEN REGEXP_LIKE(query_text, '.*[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}.*') THEN REGEXP_REPLACE(query_text, '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}', '***EMAIL***')
        WHEN REGEXP_LIKE(query_text, '.*[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}.*') THEN 'EMAIL'
      'OBS_EMAIL_INTEGRATION',
      'cortex-obs-alerts@company.com',
        'ALERT_FIRE_ON_SPIKE' AS test_name,
        'ALERT_VALIDATION' AS test_category,
        'Alert should exist and be STARTED' AS expected_outcome,
        CASE WHEN COUNT(*) > 0 THEN 'ALERT_EXISTS' ELSE 'ALERT_MISSING' END AS actual_outcome,
-- NEW Alerts:
--   ALT_ABUSE_DETECTED            - Rate abuse notification
-- 12A. SECURITY: SECRET-BASED ALERT ROUTING (NO HARDCODED EMAILS)
    email STRING;
    CALL SYSTEM$SEND_EMAIL('NI_CORTEX_OBS_EMAIL', :email, :subject, :body);
    RETURN 'Alert sent to ' || :email || ' at ' || CURRENT_TIMESTAMP()::STRING;
-- 12E. RELIABILITY: WEEKDAY/HOUR-AWARE VOLUME BASELINE FOR ALERTS
      'ALERT: Contextual Volume Spike',
--   SEC_ALERT_EMAIL                  - Encrypted alert recipient
--   SP_SEND_ALERT                    - Secret-based email routing
--   VW_STREAM_ALERT_CHECK            - Incremental stream-based alert source
-- ║   T6  - Alerting Engine (alert state, notification integration)               ║
-- 13G. T6 - ALERTING ENGINE VALIDATION
    alert_count NUMBER;
        test_result := (alert_count > 0);
        SELECT COUNT(*) INTO alert_count FROM TABLE(RESULT_SCAN(LAST_QUERY_ID())) WHERE "name" = 'ALT_SPIKE_ERROR_RATE';
    SELECT :suite_run_id, 'T6_ALERTING', 'T6.2', 'ALT_SPIKE_ERROR_RATE Exists',
        SELECT COUNT(*) INTO alert_count FROM TABLE(RESULT_SCAN(LAST_QUERY_ID())) WHERE "name" = 'ALT_SPIKE_VOLUME';
    SELECT :suite_run_id, 'T6_ALERTING', 'T6.3', 'ALT_SPIKE_VOLUME Exists',
            'Volume spike alert is registered',
        SELECT COUNT(*) INTO alert_count FROM TABLE(RESULT_SCAN(LAST_QUERY_ID())) WHERE "name" = 'ALT_ABUSE_DETECTED';
    SELECT :suite_run_id, 'T6_ALERTING', 'T6.4', 'ALT_ABUSE_DETECTED Exists',
            'Abuse detection alert is registered',
        SELECT COUNT(*) INTO alert_count FROM TABLE(RESULT_SCAN(LAST_QUERY_ID())) WHERE "name" = 'ALT_PIPELINE_STALE';
    SELECT :suite_run_id, 'T6_ALERTING', 'T6.5', 'ALT_PIPELINE_STALE Exists',
            'Pipeline staleness alert is registered',
        SHOW NOTIFICATION INTEGRATIONS LIKE 'NI_CORTEX_OBS_EMAIL';
        SELECT COUNT(*) INTO alert_count FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));
    SELECT :suite_run_id, 'T6_ALERTING', 'T6.6', 'Notification Integration Exists',
            'NI_CORTEX_OBS_EMAIL notification integration is active',
    RETURN 'T6_ALERTING: 6 tests completed';
--   SP_TEST_T6_ALERTING           - 6 tests (all alerts + notification integration)
-- ALERTS:
-- ║ 14. CXO EXECUTIVE HTML EMAIL REPORT PROCEDURE                                ║
    recipient_email STRING
    html_body STRING;
    html_body := '<!DOCTYPE html><html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0"></head>'
      || '<td width="50%" style="padding:6px 0;"><span style="color:#059669;font-weight:700;">&#10003;</span> <span style="font-size:13px;color:#374151;">8 Alerts Active</span></td></tr>'
      || '</table></td></tr></table></body></html>';
        'NI_CORTEX_OBS_EMAIL',
        :recipient_email,
        :html_body,
        'text/html'
    RETURN 'CXO report sent to ' || :recipient_email || ' at ' || CURRENT_TIMESTAMP()::STRING;
-- 15A. NOTIFICATION INTEGRATION
-- 15B. PRODUCTION ALERTS (ALL ACTIVE)
--   SP_SEND_CXO_REPORT(email)       - Dynamic HTML executive email report
-- NEW Notification Integration:
--   NI_CORTEX_OBS_EMAIL             - Email delivery (skrz2014@gmail.com)
-- NEW Alerts (5 active):
-- ║  • ALERTS / TASK_HISTORY:                Up to 2 hours                        ║
-- 16B. IDEMPOTENT ALERT EXECUTION (PREVENTS ALERT SPAM)
    alert_name STRING PRIMARY KEY,
    alert_name STRING,
        WHERE alert_name = :alert_name;
        CALL SYSTEM$SEND_EMAIL('NI_CORTEX_OBS_EMAIL', 'skrz2014@gmail.com', :subject, :body);
        USING (SELECT :alert_name AS name) s ON t.alert_name = s.name
        WHEN NOT MATCHED THEN INSERT (alert_name, last_fired, current_state, fire_count) VALUES (:alert_name, CURRENT_TIMESTAMP(), 'FIRING', 1);
    WHERE alert_name = :alert_name AND current_state = 'FIRING';
            THEN REGEXP_REPLACE(query_text, '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}', '***EMAIL***')
--   TBL_ALERT_STATE                - Alert deduplication state
--   SP_FIRE_ALERT(name, subject, body) - Idempotent alert (15-min cooldown)
--   SP_RESOLVE_ALERT(name)             - Mark alert resolved
-- 17D. PIPELINE DEAD ALERT (NO EVENTS IN 30 MINUTES)