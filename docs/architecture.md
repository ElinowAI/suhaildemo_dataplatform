# Architecture — Suhail Data Platform

## Overview

All data assets (ADF pipelines, SQL models, Power BI reports, infrastructure)
are versioned in Git and automatically promoted through 4 isolated environments
via GitHub Actions.

## Platform Architecture

```
SOURCE CONTROL
  GitHub Monorepo · Branch Protection Rulesets
         |
         | PR merge / push
         v
CI — VALIDATION  (ci.yml)
  1. Repo structure check
  2. ADF JSON lint
  3. Secret scan
  4. Build artifact → build_<SHA>.zip
         |
         | artifact: build_SHA.zip (immutable, reused across all envs)
         v
CD — PROGRESSIVE DEPLOYMENT
  env/dev  --> DEV   (automatic, 0 approval)
  env/test --> TEST  (1 reviewer required)
  env/uat  --> UAT   (1 reviewer + business sign-off)
  main     --> PROD  (2 reviewers + release runbook)
         |
         v
DEPLOYED ASSETS
  Azure Data Factory · SQL raw+silver · Power BI · Bicep IaC
```

## Core Principles

### Build Once, Deploy Many
The CI pipeline produces a single artifact named by commit SHA (build_<SHA>.zip).
That artifact is reused identically in DEV, TEST, UAT and PROD.
No environment rebuilds — immutability guaranteed.

### Immutable Artifacts
Each artifact is identified by its exact Git SHA.
Every deployment is fully traceable to its source commit.
Rollback = re-deploy a prior artifact by SHA.

### Progressive Approval Gates

| Env  | Branch    | Trigger                        | Approval                   |
|------|-----------|-------------------------------|----------------------------|
| DEV  | env/dev   | Merge feature/* into env/dev  | Automatic                  |
| TEST | env/test  | Merge env/dev into env/test   | 1 reviewer                 |
| UAT  | env/uat   | Merge env/test into env/uat   | 1 reviewer + business      |
| PROD | main      | Merge env/uat into main       | 2 reviewers + runbook      |

### Environment Isolation
Each environment has its own variable file (cicd/variables/<env>.yml)
defining Azure resource names, connection strings, and log levels.
No shared configuration between environments.

## Data Flow

```
Source System
      |
      v
ADF pl_demo_copy --> Azure Blob (source-<env>)
                           |
                           v
              SQL raw.sales_transactions
              (1 row per transaction)
                           |
              SQL transform_sales.sql
                           |
                           v
              SQL silver.sales_daily_summary
              (daily aggregation per customer)
                           |
                           v
              Power BI sales_daily_report
              (KPIs: revenue, avg order value)
```

## Repository Structure

```
.github/workflows/
  ci.yml              Validation + artifact build
  cd-dev.yml          DEV deployment (automatic)
  cd-test.yml         TEST deployment (1 approval)
  cd-uat.yml          UAT deployment (1 approval)
  cd-prod.yml         PROD deployment (2 approvals)

adf/
  pipelines/          pl_demo_copy.json
  datasets/           ds_source_blob.json, ds_sink_blob.json
  linkedServices/     ls_blob.json

sql/
  create_sales_table.sql   Phase 1 migration (Expand)
  transform_sales.sql      raw -> silver aggregation
  schema.yml               dbt schema + tests

powerbi/
  sales_report.dataset.json
  README.md

infra/
  main.bicep          IaC: Resource Group, ADF, SQL, Key Vault

cicd/
  variables/          dev.yml, test.yml, uat.yml, prod.yml
  scripts/            deploy-adf.ps1, deploy-sql.ps1,
                      deploy-powerbi.ps1, smoke-tests.ps1

docs/
  architecture.md     This document
  branching.md        Git branching strategy
  runbooks/
    release.md        Pre-release checklist
    rollback.md       Rollback procedures
```

## Rollback Strategy (4 levels)

| Level              | Method                                      | Time    |
|--------------------|---------------------------------------------|---------|
| Code + ADF + SQL   | Re-deploy prior artifact by SHA             | ~5 min  |
| ADF only           | Feature flag via Azure App Configuration    | Instant |
| SQL schema         | Expand/Contract — drop new column only      | ~2 min  |
| Infrastructure     | Re-apply prior Bicep version                | ~10 min |

## Security

- All secrets stored in Azure Key Vault
- Zero hardcoded credentials in the repository
- CI secret scan blocks any credential push
- GitHub Environments with required reviewers (approval gates)
- Branch protection rulesets on all env/* branches
