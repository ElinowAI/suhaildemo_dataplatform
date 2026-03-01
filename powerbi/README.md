# Power BI Assets

| File | Description | Source |
|------|-------------|--------|
| `sales_report.dataset.json` | Daily sales KPIs | `silver.sales_daily_summary` |

Deployed via `cicd/scripts/deploy-powerbi.ps1`.
Credentials stored in Azure Key Vault - no hardcoded values.
Dataset refresh triggered automatically after each ADF pipeline run.
