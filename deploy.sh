#!/bin/bash
set -e

echo "======================================================="
echo "SNOWFLAKE CORTEX SEARCH MONITORING DEPLOYMENT"
echo "======================================================="

FILES=(
  "01_rbac_infrastructure.sql"
  "02_enable_request_logging.sql"
  "03_vw_search_requests.sql"
  "04_monitoring_views.sql"
  "05_sla_framework.sql"
  "06_cost_attribution.sql"
  "07_pii_masking.sql"
  "08_html_alerts.sql"
  "09_test_suite.sql"
  "10_cxo_report.sql"
)

for file in "${FILES[@]}"
do
    echo "Executing: $file"
    snowsql -f "$file"
done

echo "======================================================="
echo "DEPLOYMENT COMPLETED SUCCESSFULLY"
echo "======================================================="
