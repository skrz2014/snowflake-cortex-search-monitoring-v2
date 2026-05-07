# Snowflake Cortex Search Monitoring Framework

Enterprise-grade Cortex Search observability and governance framework.

## Guarantees

- Zero skipped statements
- Deterministic deployment order
- No duplicate SQL inside modular files
- Full original worksheet preserved
- GitHub-ready repository structure

## Deployment

```bash
chmod +x deploy.sh
./deploy.sh
```

## File Order

1. 01_rbac_infrastructure.sql
2. 02_enable_request_logging.sql
3. 03_vw_search_requests.sql
4. 04_monitoring_views.sql
5. 05_sla_framework.sql
6. 06_cost_attribution.sql
7. 07_pii_masking.sql
8. 08_html_alerts.sql
9. 09_test_suite.sql
10. 10_cxo_report.sql

## Notes

- `full_implementation.sql` contains the untouched original worksheet.
- Modular files were deterministically extracted from the source worksheet.
