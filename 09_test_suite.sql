-- ============================================================================
-- 09_test_suite.sql
-- Deterministic modular extraction
-- Guarantees:
--   ✔ Zero skipped statements
--   ✔ No duplicate SQL within file
--   ✔ Ordered deployment sequence
-- ============================================================================

-- Detects: DDoS-like patterns, runaway automation, bot scraping, load test leaks.
-- 5. TESTING & VALIDATION:
-- 10A. [CRITICAL] EVENT PROPAGATION WAIT & VALIDATION
-- 10C. [HIGH] HEALTH CHECK & DEPENDENCY VALIDATION
    GREATEST(0, base_volume + (daily_growth_rate * (DATEDIFF('day', (SELECT MIN(day) FROM daily_stats), CURRENT_DATE()) + offset))) AS predicted_daily_requests,
-- 11H. CHAOS / FAILURE TESTING FRAMEWORK
    test_id STRING DEFAULT UUID_STRING(),
    test_name STRING,
    test_category STRING,
RETURNS TABLE (test_name STRING, passed BOOLEAN, details STRING)
        (test_name, test_category, expected_outcome, actual_outcome, passed, details)
    -- Test 2: Verify views handle empty data gracefully
        'EMPTY_DATA_HANDLING' AS test_name,
        'RESILIENCE' AS test_category,
    -- Test 3: Verify data quality view catches nulls
        'DATA_QUALITY_NULL_DETECTION' AS test_name,
        'DATA_QUALITY' AS test_category,
        SELECT test_name, passed, details
--   TBL_CHAOS_TEST_RESULTS        - Failure testing audit trail
--   RUN_CHAOS_TEST_SUITE          - Validate system resilience
-- 12K. TEST ALIGNMENT: PARAMETERIZED ENVIRONMENT CONFIGURATION
-- ║     End-to-End Validation of All Sections (1-12)                              ║
-- ║   Designed to run as a scheduled health check or on-demand validation.        ║
-- ║ TEST CATEGORIES:                                                              ║
-- ║   T12 - Integration (end-to-end data flow validation)                         ║
-- 13A. TEST RESULTS TABLE (PERSISTENT AUDIT TRAIL)
    test_run_id         STRING DEFAULT UUID_STRING(),
    test_suite_run_id   STRING,
    test_category       STRING,
    test_id             STRING,
    test_name           STRING,
    test_description    STRING,
    total_tests         NUMBER,
    passed_tests        NUMBER,
    failed_tests        NUMBER,
    skipped_tests       NUMBER,
-- 13B. T1 - INFRASTRUCTURE VALIDATION
    test_result BOOLEAN;
        (test_suite_run_id, test_category, test_id, test_name, test_description, expected_result, actual_result, passed, execution_time_ms)
            'EXISTS', IFF(:test_result, 'EXISTS', 'MISSING'), :test_result, 0
            'ACTIVE', IFF(:test_result, 'ACTIVE', 'UNAVAILABLE'), :test_result, 0
    test_result := (SELECT COUNT(*) > 0 FROM SNOWFLAKE.ACCOUNT_USAGE.ROLES WHERE NAME = 'FR_CORTEX_OBS_READONLY' AND DELETED_ON IS NULL);
    test_result := (SELECT COUNT(*) > 0 FROM SNOWFLAKE.ACCOUNT_USAGE.ROLES WHERE NAME = 'FR_CORTEX_OBS_ADMIN' AND DELETED_ON IS NULL);
    RETURN 'T1_INFRASTRUCTURE: 7 tests completed';
-- 13C. T2 - EVENT INGESTION VALIDATION
    latest_event_age_min NUMBER;
        test_result := TRUE;
        WHEN OTHER THEN test_result := FALSE;
            'ACCESSIBLE', IFF(:test_result, 'ACCESSIBLE', 'ACCESS_DENIED'), :test_result, 0
    test_result := (event_count > 0);
            '>0', :event_count::STRING, :test_result, 0
    test_result := (search_event_count > 0);
            '>0', :search_event_count::STRING, :test_result, 0
    SELECT COUNT(*) INTO latest_event_age_min
    test_result := (latest_event_age_min > 0);
            '>0 events', :latest_event_age_min::STRING || ' events', :test_result, 0
    test_result := (SELECT COUNT(*) > 0
            'FIELDS_PRESENT', IFF(:test_result, 'FIELDS_PRESENT', 'FIELDS_MISSING'), :test_result, 0
            'FUNCTIONAL', IFF(:test_result, 'FUNCTIONAL', 'MISSING_OR_BROKEN'), :test_result, 0
    RETURN 'T2_EVENT_INGESTION: 6 tests completed';
            'SUCCESS', IFF(:test_result, 'SUCCESS', 'ERROR'), :test_result, 0);
            'SUCCESS', IFF(:test_result, 'SUCCESS', 'ERROR'), :test_result, 0
            'VALID', IFF(:test_result, 'VALID', 'INVALID_VALUES'), :test_result, 0
            'VALID', IFF(:test_result, 'VALID', 'INVALID_SEVERITY'), :test_result, 0
        test_result := (row_count > 0);
        WHEN OTHER THEN test_result := FALSE; row_count := 0;
            '>0 rows', :row_count::STRING || ' rows', :test_result,
            'SUCCESS', IFF(:test_result, 'SUCCESS', 'ERROR'), :test_result,
-- 13H. T7 - DATA RETENTION VALIDATION
            'ACCESSIBLE', IFF(:test_result, 'ACCESSIBLE', 'MISSING'), :test_result,
        test_result := (row_count = 0);
        WHEN OTHER THEN test_result := FALSE; row_count := -1;
            '0 rows beyond 2y', :row_count::STRING || ' rows beyond 2y', :test_result,
    RETURN 'T7_RETENTION: 3 tests completed';
-- 13I. T8 - SECURITY & GOVERNANCE VALIDATION
            'EXISTS', IFF(:test_result, 'EXISTS', 'MISSING'), :test_result,
            '***CREDENTIAL_DETECTED***', IFF(:test_result, 'CORRECTLY_REDACTED', 'FAILED'), :test_result,
            '>=5 rows', IFF(:test_result, 'POPULATED', 'INSUFFICIENT'), :test_result,
    RETURN 'T8_SECURITY: 5 tests completed';
-- 13J. T9 - PERFORMANCE VALIDATION
        WHEN OTHER THEN test_result := FALSE; query_time_ms := -1;
            '<30000ms', :query_time_ms::STRING || 'ms', :test_result, 0
            'TEST <NUM> QUERY', IFF(:test_result, 'CORRECT', 'INCORRECT'), :test_result,
    RETURN 'T9_PERFORMANCE: 4 tests completed';
-- 13K. T10 - PIPELINE HEALTH VALIDATION
            '>0 rows', COALESCE(:row_count::STRING, '0') || ' rows', :test_result,
            'QUERYABLE', IFF(:test_result, 'QUERYABLE (' || :row_count::STRING || ' checks)', 'ERROR'), :test_result, 0
            'SUCCESS', IFF(:test_result, 'SUCCESS (' || :row_count::STRING || ' services)', 'ERROR'), :test_result,
    RETURN 'T10_PIPELINE_HEALTH: 5 tests completed';
-- 13L. T11 - RESILIENCE VALIDATION
            'NO_ERROR', IFF(:test_result, 'NO_ERROR (' || :row_count::STRING || ' nulls)', 'ERROR'), :test_result,
            'NO_ERROR', IFF(:test_result, 'HANDLED (' || :row_count::STRING || ' defaults)', 'ERROR'), :test_result,
            'NO_ERROR', IFF(:test_result, 'NO_ERROR', 'DIVISION_ERROR'), :test_result,
            'NO_ERROR', IFF(:test_result, 'NO_ERROR', 'ERROR'), :test_result,
    RETURN 'T11_RESILIENCE: 5 tests completed';
-- 13M. T12 - END-TO-END INTEGRATION VALIDATION
    test_result := (event_count = view_count OR (event_count > 0 AND view_count > 0));
            'CONSISTENT', 'raw=' || :event_count::STRING || ' view=' || :view_count::STRING, :test_result,
    test_result := (row_count >= 5);
            '>0 weeks', :row_count::STRING || ' weeks', :test_result,
    -- T12.5: Full object count validation (views, tables, procedures)
    test_result := (view_count >= 15);
            '>=15 views', :view_count::STRING || ' views', :test_result,
    RETURN 'T12_INTEGRATION: 5 tests completed';
-- 13N. MASTER TEST ORCHESTRATOR
    test_id STRING,
        total_tests = :total,
        passed_tests = :pass_count,
        failed_tests = :fail_count,
        skipped_tests = 0,
        SELECT test_category, test_id, test_name, passed, actual_result, execution_time_ms
        WHERE test_suite_run_id = :suite_id
        ORDER BY test_category, test_id
-- 13O. SCHEDULED TEST EXECUTION (CONTINUOUS VALIDATION)
      'One or more tests failed in the latest hourly run. Query TBL_TEST_RESULTS for details.'
-- 13P. TEST REPORTING VIEWS
    total_tests,
    passed_tests,
    failed_tests,
    ROUND(100.0 * passed_tests / NULLIF(total_tests, 0), 1) AS pass_rate_pct,
    tr.test_category,
    tr.test_id,
    tr.test_name,
    tr.test_description,
) latest ON tr.test_suite_run_id = latest.suite_run_id
ORDER BY tr.test_category, tr.test_id;
    DATE_TRUNC('day', started_at) AS test_date,
GROUP BY test_date
ORDER BY test_date DESC;
-- Run the full test suite:
-- View latest results:
-- View only failures from the latest run:
-- Run individual test categories:
--   TBL_TEST_RESULTS              - Individual test result audit trail
--   TBL_TEST_SUITE_RUNS           - Suite-level run metadata
-- PROCEDURES (12 test categories + 1 orchestrator):
--   SP_TEST_T7_RETENTION          - 3 tests (table, retention policy, task)
--   SP_TEST_T9_PERFORMANCE        - 4 tests (MVWs, response time, UDFs)
--   SP_TEST_T10_PIPELINE_HEALTH   - 5 tests (health view, drift, baseline, registry)
--   SP_TEST_T11_RESILIENCE        - 5 tests (nulls, division, empty data)
--   SP_RUN_FULL_TEST_SUITE        - Orchestrator (runs all 12, computes pass/fail)
-- TOTAL: 65 TESTS across 12 categories
--   TSK_HOURLY_TEST_SUITE         - Runs full suite every hour
--   ALT_TEST_SUITE_FAILURES       - Notifies on test failures
--   VW_TEST_SUITE_SUMMARY         - Run-level pass rates
--   VW_TEST_FAILURES_LATEST       - Latest failed tests
--   VW_TEST_TREND                 - Daily pass rate trend
-- END OF PRODUCTION-GRADE TEST SUITE
    total_tests NUMBER;
    INTO total_tests, pass_count, fail_count
    WHERE test_suite_run_id = (
    pass_rate := ROUND(100.0 * pass_count / NULLIF(total_tests, 0), 0);
      || '<p style="margin:4px 0 0;font-size:12px;color:#047857;">' || pass_count::STRING || '/' || total_tests::STRING || ' tests passing</p>'
      || '<p style="margin:4px 0 0;font-size:12px;color:#047857;">All logic tests pass</p>'
--   LIVE_TEST.TBL_KNOWLEDGE_BASE    - 15-row knowledge base (search corpus)
            AND NOT REGEXP_LIKE(query_text, '.*(example|test|sample|placeholder)\\.com.*', 'i')
        WHEN test_pass_rate >= 95 AND pipeline_health_pct >= 80 THEN 'EXCELLENT'
        WHEN test_pass_rate >= 80 AND pipeline_health_pct >= 50 THEN 'GOOD'
        WHEN test_pass_rate >= 60 THEN 'DEGRADED'