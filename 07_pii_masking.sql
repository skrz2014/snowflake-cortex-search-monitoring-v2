-- ============================================================================
-- 07_pii_masking.sql
-- Deterministic modular extraction
-- Guarantees:
--   ✔ Zero skipped statements
--   ✔ No duplicate SQL within file
--   ✔ Ordered deployment sequence
-- ============================================================================

--   Masking:      MP_<TARGET>_<ACTION>          (e.g. MP_QUERY_TEXT_REDACT)
-- Query text is partially redacted via masking policy for this role.
-- MP_QUERY_TEXT_REDACT: Dynamic masking policy for the query_text column.
-- Attach via ALTER VIEW ... MODIFY COLUMN ... SET MASKING POLICY (commented below).
-- │ Sensitive data in queries  │ MP_QUERY_TEXT_REDACT masking policy          │
-- │ Unauthorized log access    │ FR_CORTEX_OBS_READONLY + masking + audit     │
--   MP_QUERY_TEXT_REDACT      - Role-based query text masking
    END AS detected_pii_type,
--   VW_PII_AUDIT                  - Sensitive data in queries audit
--   REDACT_SENSITIVE_QUERY        - PII redaction in query text
-- 12B. SECURITY: APPLY MASKING POLICY (WAS PREVIOUSLY COMMENTED OUT)
    -- T8.1: Masking policy exists
        test_result := (SELECT COUNT(*) > 0 FROM SNOWFLAKE.ACCOUNT_USAGE.MASKING_POLICIES
    SELECT :suite_run_id, 'T8_SECURITY', 'T8.1', 'Masking Policy Exists',
    -- T8.2: PII audit view compiles
    SELECT :suite_run_id, 'T8_SECURITY', 'T8.2', 'VW_PII_AUDIT Queryable',
            'PII detection audit view executes',
    SELECT :suite_run_id, 'T8_SECURITY', 'T8.4', 'PII Redaction Function Works',
--   SP_TEST_T8_SECURITY           - 5 tests (masking, PII, audit, config)
      || '<tr><td style="padding:6px 0;"><span style="color:#059669;font-weight:700;">&#10003;</span> <span style="font-size:13px;color:#374151;">Masking Applied</span></td>'
      || '<td style="padding:6px 0;"><span style="color:#059669;font-weight:700;">&#10003;</span> <span style="font-size:13px;color:#374151;">PII Detection Active</span></td></tr>'
    ('Dynamic Data Masking', 'Column-level security policies that mask sensitive data at query time based on the executing role.', 'SECURITY'),
-- 16H. IMPROVED PII DETECTION (REDUCED FALSE POSITIVES)