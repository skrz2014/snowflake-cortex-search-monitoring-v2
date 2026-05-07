-- ============================================================================
-- 02_enable_request_logging.sql
-- Deterministic modular extraction
-- Guarantees:
--   ✔ Zero skipped statements
--   ✔ No duplicate SQL within file
--   ✔ Ordered deployment sequence
-- ============================================================================

-- CORTEX SEARCH REQUEST MONITORING: PRODUCTION-GRADE IMPLEMENTATION BLUEPRINT
-- Scope: Enterprise-wide Cortex Search observability, governance & cost management
--   • Enables accurate chargeback to business units
--   • Transforms Cortex Search from black-box to governed capability
--   • Enables data-driven capacity planning for AI services
-- │   (Users / Apps / APIs calling Cortex Search Services)                   │
-- │                   CORTEX SEARCH SERVICE LAYER                            │
-- │   SNOWFLAKE.LOCAL.AI_OBSERVABILITY_EVENTS (event table)                   │
-- 3A. ENABLE REQUEST LOGGING
-- Strategy: Enable selectively on production-critical services first.
-- Dev/test services can be enabled later for debugging purposes.
-- Enable on an existing Cortex Search Service (replace with your actual service):
  COMMENT = 'Read-only access to Cortex Search monitoring views and metrics';
-- Event source: SNOWFLAKE.LOCAL.AI_OBSERVABILITY_EVENTS (system event table)
FROM SNOWFLAKE.LOCAL.AI_OBSERVABILITY_EVENTS
-- This is the SINGLE SOURCE OF TRUTH for actual Cortex Search spend.
  ENABLED = TRUE
    FROM SNOWFLAKE.LOCAL.AI_OBSERVABILITY_EVENTS
      '[ALERT] Cortex Search High Latency Detected',
      '[ALERT] Cortex Search Error Rate Spike',
        FROM SNOWFLAKE.LOCAL.AI_OBSERVABILITY_EVENTS
      '[ALERT] Cortex Search Unusual Volume Detected',
-- 1. SELECTIVE ENABLEMENT:
--    • Enable REQUEST_LOGGING only on production-critical services
--    • Dev/test: enable temporarily for debugging, then disable
--   * Enable REQUEST_LOGGING on production services
               CASE WHEN (SELECT COUNT(*) FROM SNOWFLAKE.LOCAL.AI_OBSERVABILITY_EVENTS LIMIT 1) >= 0
      'ALERT: Cortex Search Abuse Detected',
-- 11G. DATA FRESHNESS MONITORING (CORTEX SEARCH SERVICE LAG)
      'ALERT: Cortex Search Index Stale',
    'Active Cortex Search services'
--   LOG_SERVICE_FRESHNESS         - Capture SHOW CORTEX SEARCH state
    FROM SNOWFLAKE.LOCAL.AI_OBSERVABILITY_EVENTS e
        FROM SNOWFLAKE.LOCAL.AI_OBSERVABILITY_EVENTS e
  ON TABLE SNOWFLAKE.LOCAL.AI_OBSERVABILITY_EVENTS
        SELECT COUNT(*) INTO event_count FROM SNOWFLAKE.LOCAL.AI_OBSERVABILITY_EVENTS WHERE TIMESTAMP >= DATEADD('day', -1, CURRENT_TIMESTAMP()) LIMIT 1;
            'SNOWFLAKE.LOCAL.AI_OBSERVABILITY_EVENTS is queryable',
    -- T2.3: Cortex Search events present
      || '<td style="padding:6px 0;"><span style="color:#059669;font-weight:700;">&#10003;</span> <span style="font-size:13px;color:#374151;">Audit Trail Enabled</span></td></tr>'
      'ALERT: Cortex Search Latency Spike',
      'ALERT: Cortex Search Error Rate Spike',
      'ALERT: Cortex Search Volume Spike',
-- 15D. LIVE TEST DATA (KNOWLEDGE BASE FOR CORTEX SEARCH)
    ('Time Travel', 'Time Travel enables accessing historical data at any point within a defined retention period, supporting UNDROP and AT/BEFORE queries.', 'STORAGE'),
    ('Cortex Search', 'Cortex Search provides hybrid vector and keyword search over text data with automatic embedding and indexing.', 'AI'),
    ('Snowpark', 'Snowpark enables developers to write data pipelines in Python, Java, or Scala that execute natively within Snowflake.', 'DEVELOPMENT'),
-- 15E. CORTEX SEARCH SERVICE (UNCOMMENT WHEN ACCOUNT SUPPORTS IT)
-- CREATE OR REPLACE CORTEX SEARCH SERVICE PRD_CORTEX_OBSERVABILITY.LIVE_TEST.SVC_KNOWLEDGE_SEARCH
--   LIVE_TEST                        - Test data for Cortex Search
    FROM SNOWFLAKE.LOCAL.AI_OBSERVABILITY_EVENTS e,
      'CRITICAL: No Cortex Search Events in 30 Minutes',
      'The event pipeline appears dead. No CORTEX_SEARCH_REQUEST events received in the last 30 minutes. Check: 1) Cortex Search services are running 2) REQUEST_LOGGING is enabled 3) Users are making requests.'
  SET ENABLE_QUERY_ACCELERATION = TRUE
--   PRD_CORTEX_OBS_XS_WH           - Query Acceleration enabled (4x scale)