# Rollback Runbook — Suhail Data Platform

## When to Rollback

Trigger rollback if within 30 min of a PROD release:
- ADF pipeline error rate > 0%
- SQL query results are incorrect
- Power BI data discrepancies
- Smoke tests failing in PROD

## Rollback Methods

### 1. Artifact Rollback (primary — code + ADF + SQL)
Re-deploy the last known-good artifact by SHA.
```
Last stable PROD SHA: ________________________________
```
Steps: GitHub Actions --> CD - Deploy to PROD --> Run workflow --> enter prior SHA

### 2. Feature Flag (ADF — instant, zero downtime)
- Azure App Configuration --> disable the affected pipeline flag
- No re-deployment needed, takes effect immediately

### 3. SQL Expand/Contract
- Phase 1 (Expand):  safe — old column still exists, drop new column only
- Phase 2 (Migrate): stop migration job, verify old column integrity
- Phase 3 (Contract): old column already dropped — use Artifact rollback

### 4. Infrastructure Bicep
```bash
az deployment sub create \
  --location eastus \
  --template-file infra/main.bicep \
  --parameters environment=prod
```

## Post-Rollback Checklist

- [ ] Smoke tests passing after rollback
- [ ] Incident documented with root cause
- [ ] Team notified

| Field              | Value |
|--------------------|-------|
| Incident date      |       |
| Rolled back to SHA |       |
| Method used        |       |
| Performed by       |       |
