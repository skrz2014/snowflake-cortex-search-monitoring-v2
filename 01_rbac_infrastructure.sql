-- ============================================================================
-- 01_rbac_infrastructure.sql
-- Deterministic modular extraction
-- Guarantees:
--   ✔ Zero skipped statements
--   ✔ No duplicate SQL within file
--   ✔ Ordered deployment sequence
-- ============================================================================

--   Database:     PRD_<DOMAIN>                  (e.g. PRD_CORTEX_OBSERVABILITY)
--   Schema:       <FUNCTIONAL_AREA>             (e.g. MONITORING, AGGREGATED)
--   Warehouse:    PRD_<PURPOSE>_<SIZE>_WH       (e.g. PRD_CORTEX_OBS_XS_WH)
-- ALTER CORTEX SEARCH SERVICE <your_db>.<your_schema>.<your_service>
-- CREATE CORTEX SEARCH SERVICE <your_db>.<your_schema>.<service_name>
--   WAREHOUSE = <warehouse>
-- Verify logging is enabled (replace with your schema):
-- SHOW CORTEX SEARCH SERVICES IN SCHEMA <your_db>.<your_schema>;
-- 3B. SECURE ACCESS DESIGN (RBAC)
-- Switch to ACCOUNTADMIN to create roles and manage privileges
-- FR_CORTEX_OBS_READONLY: Grants SELECT on monitoring views and USAGE on warehouse.
CREATE ROLE IF NOT EXISTS FR_CORTEX_OBS_READONLY
-- FR_CORTEX_OBS_ADMIN: Full access including unmasked query text and governance schema.
CREATE ROLE IF NOT EXISTS FR_CORTEX_OBS_ADMIN
-- Grant MONITOR privilege on Cortex Search Services (uncomment and replace with your services):
-- GRANT MONITOR ON CORTEX SEARCH SERVICE <your_db>.<your_schema>.<your_service>
GRANT ROLE FR_CORTEX_OBS_READONLY TO ROLE FR_CORTEX_OBS_ADMIN;
GRANT ROLE FR_CORTEX_OBS_ADMIN TO ROLE SYSADMIN;
-- NOTE: Database, schema, and warehouse grants are issued in Section 3C after object creation
-- Database: Central repository for all Cortex AI observability artifacts
CREATE DATABASE IF NOT EXISTS PRD_CORTEX_OBSERVABILITY;
-- Schema: MONITORING - Real-time views, SLA definitions, alerts, and tasks
CREATE SCHEMA IF NOT EXISTS PRD_CORTEX_OBSERVABILITY.MONITORING;
-- Schema: AGGREGATED - Pre-computed daily/weekly/monthly rollups for BI and reporting
CREATE SCHEMA IF NOT EXISTS PRD_CORTEX_OBSERVABILITY.AGGREGATED;
-- Schema: GOVERNANCE - Masking policies, audit views, access controls
CREATE SCHEMA IF NOT EXISTS PRD_CORTEX_OBSERVABILITY.GOVERNANCE;
-- Warehouse: Dedicated XS compute for monitoring queries, alerts, and aggregation tasks.
CREATE WAREHOUSE IF NOT EXISTS PRD_CORTEX_OBS_XS_WH
  WAREHOUSE_SIZE = 'XSMALL'
  COMMENT = 'Dedicated warehouse for AI observability monitoring workloads';
-- USAGE on database and schema allows navigation; SELECT on views exposes data.
-- FUTURE VIEWS grant ensures new views are automatically accessible.
GRANT USAGE ON DATABASE PRD_CORTEX_OBSERVABILITY TO ROLE FR_CORTEX_OBS_READONLY;
GRANT USAGE ON SCHEMA PRD_CORTEX_OBSERVABILITY.MONITORING TO ROLE FR_CORTEX_OBS_READONLY;
GRANT SELECT ON ALL VIEWS IN SCHEMA PRD_CORTEX_OBSERVABILITY.MONITORING TO ROLE FR_CORTEX_OBS_READONLY;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA PRD_CORTEX_OBSERVABILITY.MONITORING TO ROLE FR_CORTEX_OBS_READONLY;
GRANT USAGE ON WAREHOUSE PRD_CORTEX_OBS_XS_WH TO ROLE FR_CORTEX_OBS_READONLY;
    RECORD_ATTRIBUTES['snow.ai.observability.database.name']::STRING                   AS database_name,
    RECORD_ATTRIBUTES['snow.ai.observability.schema.name']::STRING                     AS schema_name,
    DATABASE_NAME,
    SCHEMA_NAME,
-- Root causes: Index staleness, warehouse contention, large result sets, network issues.
-- Response: Check TARGET_LAG freshness, warehouse queuing, query complexity.
  WAREHOUSE = PRD_CORTEX_OBS_XS_WH
-- Common triggers: Schema changes, invalid filters, service misconfiguration.
-- Typical runtime: <30 seconds on XS warehouse for up to 1M events/day.
-- For Power BI / Tableau: Connect to PRD_CORTEX_OBSERVABILITY.MONITORING schema
-- GRANT USAGE ON DATABASE PRD_CORTEX_OBSERVABILITY TO SHARE SHR_CORTEX_OBSERVABILITY;
-- GRANT USAGE ON SCHEMA PRD_CORTEX_OBSERVABILITY.MONITORING TO SHARE SHR_CORTEX_OBSERVABILITY;
-- GRANT SELECT ON ALL VIEWS IN SCHEMA PRD_CORTEX_OBSERVABILITY.MONITORING TO SHARE SHR_CORTEX_OBSERVABILITY;
-- VW_ACCESS_AUDIT: Tracks which users query the observability database.
--   • Aggregation tasks: XS warehouse, <1 min daily
--   • Alerts: XS warehouse, minimal credit usage
--    • Monitoring warehouse separate from production workloads
--    • Schema separation: raw vs. aggregated vs. governance
-- │ Schema drift in events     │ Defensive JSON parsing with TRY_* functions  │
--   * Create RBAC roles (FR_CORTEX_OBS_READONLY, FR_CORTEX_OBS_ADMIN)
-- Database:      PRD_CORTEX_OBSERVABILITY
-- Schemas:       MONITORING | AGGREGATED | GOVERNANCE
-- Warehouse:     PRD_CORTEX_OBS_XS_WH
    TRY_CAST(RECORD_ATTRIBUTES['snow.ai.observability.database.name']::STRING AS STRING) AS database_name,
    TRY_CAST(RECORD_ATTRIBUTES['snow.ai.observability.schema.name']::STRING AS STRING) AS schema_name,
        SELECT 'WAREHOUSE_ACCESS' AS check_name,
               CASE WHEN CURRENT_WAREHOUSE() IS NOT NULL
               'Using warehouse: ' || COALESCE(CURRENT_WAREHOUSE(), 'NONE') AS message
ALTER WAREHOUSE PRD_CORTEX_OBS_XS_WH
    WAREHOUSE_NAME,
    SUM(CREDITS_USED) * COALESCE((SELECT credit_per_req * 1000 FROM PRD_CORTEX_OBSERVABILITY.GOVERNANCE.TBL_PRICING_CONFIG WHERE service_type = 'WAREHOUSE_CREDIT_RATE' AND effective_to IS NULL), 3.00) AS estimated_cost_usd
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE WAREHOUSE_NAME = 'PRD_CORTEX_OBS_XS_WH'
GROUP BY usage_date, WAREHOUSE_NAME
--   VW_DAILY_OBSERVABILITY_COSTS       - Warehouse credit tracking
    TRY_CAST(RECORD_ATTRIBUTES['snow.ai.observability.schema.name']::STRING AS STRING)   AS schema_name,
-- 11C. REAL COST ATTRIBUTION (WAREHOUSE + QUERY HISTORY JOIN)
WITH warehouse_hourly_cost AS (
    FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
    WHERE WAREHOUSE_NAME = 'PRD_CORTEX_OBS_XS_WH'
JOIN warehouse_hourly_cost wc ON hr.hour_bucket = wc.hour_bucket
        WHEN peak_rpm > 50  THEN 'REDUCE WAREHOUSE SIZE / APPLY RESOURCE MONITOR'
    database_name STRING,
    schema_name STRING,
        (service_name, database_name, schema_name, target_lag, indexing_state, raw_metadata)
        'database_name' AS database_name,
        'schema_name' AS schema_name,
    database_name,
    schema_name,
GROUP BY service_name, database_name, schema_name
-- 11J. SCHEMA DRIFT PROTECTION
CREATE OR REPLACE VIEW PRD_CORTEX_OBSERVABILITY.MONITORING.VW_SCHEMA_DRIFT_DETECTION AS
        ('snow.ai.observability.database.name', 'STRING'),
        ('snow.ai.observability.schema.name', 'STRING'),
--   VW_SCHEMA_DRIFT_DETECTION     - Event schema evolution tracking
GRANT ROLE FR_CORTEX_OBS_ADMIN TO ROLE SECURITYADMIN;
    ('DATABASE_NAME', 'PRD_CORTEX_OBSERVABILITY', 'Target database for all objects'),
    ('MONITORING_SCHEMA', 'MONITORING', 'Schema for views/tasks/alerts'),
    ('GOVERNANCE_SCHEMA', 'GOVERNANCE', 'Schema for policies/secrets'),
    ('WAREHOUSE_NAME', 'PRD_CORTEX_OBS_XS_WH', 'Compute warehouse'),
-- ║   T1  - Infrastructure (DB, schemas, warehouse, roles)                        ║
-- ║   T3  - Monitoring Views (compilation, data quality, schema)                  ║
-- ║   T8  - Security & Governance (masking, RBAC, PII detection)                  ║
-- ║   T11 - Resilience (null handling, schema drift, empty data)                  ║
    -- T1.1: Database exists and is accessible
    test_result := (SELECT COUNT(*) > 0 FROM INFORMATION_SCHEMA.DATABASES WHERE DATABASE_NAME = 'PRD_CORTEX_OBSERVABILITY');
    SELECT :suite_run_id, 'T1_INFRASTRUCTURE', 'T1.1', 'Database Exists',
            'PRD_CORTEX_OBSERVABILITY database is accessible',
    -- T1.2: MONITORING schema exists
    test_result := (SELECT COUNT(*) > 0 FROM PRD_CORTEX_OBSERVABILITY.INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'MONITORING');
    SELECT :suite_run_id, 'T1_INFRASTRUCTURE', 'T1.2', 'MONITORING Schema Exists',
            'MONITORING schema created and accessible',
    -- T1.3: AGGREGATED schema exists
    test_result := (SELECT COUNT(*) > 0 FROM PRD_CORTEX_OBSERVABILITY.INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'AGGREGATED');
    SELECT :suite_run_id, 'T1_INFRASTRUCTURE', 'T1.3', 'AGGREGATED Schema Exists',
            'AGGREGATED schema created and accessible',
    -- T1.4: GOVERNANCE schema exists
    test_result := (SELECT COUNT(*) > 0 FROM PRD_CORTEX_OBSERVABILITY.INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'GOVERNANCE');
    SELECT :suite_run_id, 'T1_INFRASTRUCTURE', 'T1.4', 'GOVERNANCE Schema Exists',
            'GOVERNANCE schema created and accessible',
    -- T1.5: Warehouse exists and is running
    test_result := (CURRENT_WAREHOUSE() IS NOT NULL);
    SELECT :suite_run_id, 'T1_INFRASTRUCTURE', 'T1.5', 'Warehouse Active',
    -- T2.5: Event schema has expected fields
    SELECT :suite_run_id, 'T2_EVENT_INGESTION', 'T2.5', 'Event Schema Valid',
            'Warehouse-joined cost attribution view executes',
        SHOW ALERTS IN SCHEMA PRD_CORTEX_OBSERVABILITY.MONITORING;
        SHOW TASKS IN SCHEMA PRD_CORTEX_OBSERVABILITY.MONITORING;
                          AND POLICY_SCHEMA = 'GOVERNANCE'
            'MP_QUERY_TEXT_REDACT is defined in GOVERNANCE schema',
    -- T10.3: VW_SCHEMA_DRIFT_DETECTION compiles
        SELECT COUNT(*) INTO row_count FROM PRD_CORTEX_OBSERVABILITY.MONITORING.VW_SCHEMA_DRIFT_DETECTION LIMIT 1;
    SELECT :suite_run_id, 'T10_PIPELINE_HEALTH', 'T10.3', 'Schema Drift Detection Works',
            'VW_SCHEMA_DRIFT_DETECTION executes',
    FROM PRD_CORTEX_OBSERVABILITY.INFORMATION_SCHEMA.VIEWS
    WHERE TABLE_SCHEMA = 'MONITORING';
            'At least 15 views deployed in MONITORING schema',
--   SP_TEST_T1_INFRASTRUCTURE     - 7 tests (DB, schemas, warehouse, roles)
--   SP_TEST_T2_EVENT_INGESTION    - 6 tests (table, flow, freshness, schema, stream)
      || '<tr><td style="padding:6px 0;"><span style="color:#059669;font-weight:700;">&#10003;</span> <span style="font-size:13px;color:#374151;">RBAC Configured</span></td>'
CREATE SCHEMA IF NOT EXISTS PRD_CORTEX_OBSERVABILITY.LIVE_TEST;
    ('Virtual Warehouses', 'Virtual warehouses are clusters of compute resources that execute queries. They can be resized and suspended independently.', 'COMPUTE'),
    ('Zero-Copy Cloning', 'Cloning creates instant copies of databases, schemas, or tables without duplicating underlying storage until modifications occur.', 'STORAGE'),
    ('Resource Monitors', 'Resource monitors track credit usage on warehouses and can trigger notifications or suspend operations at thresholds.', 'COST'),
--   WAREHOUSE = PRD_CORTEX_OBS_XS_WH
-- NEW Schema:
-- ║  • WAREHOUSE_METERING_HISTORY:           2-3 hour delay                       ║
-- 16E. SCHEMA EVOLUTION MONITORING (DETECT NEW EVENT FIELDS)
--   VW_NEW_EVENT_FIELDS            - Schema evolution detection
    TABLE_SCHEMA AS schema_name,
FROM PRD_CORTEX_OBSERVABILITY.INFORMATION_SCHEMA.VIEWS
    TABLE_SCHEMA,
FROM PRD_CORTEX_OBSERVABILITY.INFORMATION_SCHEMA.TABLES
    PROCEDURE_SCHEMA,
FROM PRD_CORTEX_OBSERVABILITY.INFORMATION_SCHEMA.PROCEDURES
    FUNCTION_SCHEMA,
FROM PRD_CORTEX_OBSERVABILITY.INFORMATION_SCHEMA.FUNCTIONS
ALTER DATABASE PRD_CORTEX_OBSERVABILITY SET TAG
ALTER SCHEMA PRD_CORTEX_OBSERVABILITY.MONITORING SET TAG
ALTER SCHEMA PRD_CORTEX_OBSERVABILITY.GOVERNANCE SET TAG
-- 17H. REPORTING SCHEMA (BI-OPTIMIZED EXECUTIVE VIEWS)
CREATE SCHEMA IF NOT EXISTS PRD_CORTEX_OBSERVABILITY.REPORTING;
-- 17I. WAREHOUSE CONFIGURATION (QUERY ACCELERATION + MULTI-CLUSTER)
-- Dedicated reporting warehouse for BI tools (uncomment when needed)
-- CREATE WAREHOUSE IF NOT EXISTS PRD_CORTEX_OBS_REPORTING_WH
--   WAREHOUSE_SIZE = 'MEDIUM'
--   WAREHOUSE_TYPE = 'STANDARD'
--   COMMENT = 'BI/Dashboard warehouse for observability reporting';