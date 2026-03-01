# Suhail Data Platform — CI/CD Reference

## Overview

This repository implements a fully automated CI/CD pipeline for a data platform on Azure.
All assets (ADF pipelines, SQL models, Power BI reports, infrastructure) are treated as code,
versioned in Git, and promoted through four isolated environments via GitHub Actions.

---

## Repository Structure

```
.github/workflows/
  ci.yml              Validation + immutable artifact build (triggered on every PR)
  cd-dev.yml          Deploy to DEV  (automatic after CI passes on env/dev)
  cd-test.yml         Deploy to TEST (1 reviewer approval required)
  cd-uat.yml          Deploy to UAT  (1 reviewer approval required)
  cd-prod.yml         Deploy to PROD (2 reviewer approvals + release runbook)

adf/
  pipelines/          pl_demo_copy.json
  datasets/           ds_source_blob.json, ds_sink_blob.json
  linkedServices/     ls_blob.json

sql/
  create_sales_table.sql   Migration Phase 1 (Expand/Contract pattern)
  transform_sales.sql      Raw -> Silver aggregation
  schema.yml               dbt schema definitions and column tests

powerbi/
  sales_report.dataset.json    Power BI dataset definition
  README.md

infra/
  main.bicep          Bicep IaC - Resource Group, ADF, SQL Server, Key Vault

cicd/
  variables/          dev.yml, test.yml, uat.yml, prod.yml (per-env config)
  scripts/            deploy-adf.ps1, deploy-sql.ps1, deploy-powerbi.ps1, smoke-tests.ps1

docs/
  PLATFORM.md         This document
```

---

## Branch Strategy

```
feature/* --> env/dev --> env/test --> env/uat --> main
              (auto)    (1 approval) (1 approval) (2 approvals)
```

| Branch     | Environment | Gate                              |
|------------|-------------|-----------------------------------|
| feature/*  | —           | None, auto-deleted after merge    |
| env/dev    | DEV         | PR required + CI status check     |
| env/test   | TEST        | 1 reviewer + CI status check      |
| env/uat    | UAT         | 1 reviewer + CI status check      |
| main       | PROD        | 2 reviewers + CI + release runbook|

### Developer workflow

```bash
# 1. Create a feature branch from env/dev
git checkout env/dev && git pull origin env/dev
git checkout -b feature/my-change

# 2. Develop, commit, push
git add . && git commit -m "feat: describe the change"
git push origin feature/my-change

# 3. Open PR -> env/dev   (CI runs, then CD-DEV auto-deploys on merge)
# 4. Open PR -> env/test  (1 reviewer approval -> CD-TEST)
# 5. Open PR -> env/uat   (1 reviewer + business sign-off -> CD-UAT)
# 6. Open PR -> main      (2 reviewers + runbook -> CD-PROD)
```

---

## CI Pipeline (ci.yml)

Triggered on: every push and pull request.

Steps:
1. **Structure check** — verify expected folders exist
2. **ADF JSON lint** — validate all ADF JSON files with `jq`
3. **Secret scan** — grep for hardcoded credentials, fail if found
4. **Artifact build** — zip all assets into `build_<SHA>.zip`
5. **Upload artifact** — store as GitHub Actions artifact (named by commit SHA)

The artifact is the single deployable unit reused across all environments.
No environment performs its own build.

---

## CD Pipelines

All CD workflows follow the same pattern:

1. Triggered by `workflow_run` when CI completes with `success`
2. Branch filter ensures the right CD runs for the right environment
3. Download the CI artifact (identified by SHA)
4. Validate ADF JSON (pre-deploy gate)
5. Deploy assets (ADF, SQL, Power BI) via deployment scripts
6. Run smoke tests to confirm healthy deployment

| Workflow    | Trigger branch | Environment | Approval      |
|-------------|---------------|-------------|---------------|
| cd-dev.yml  | env/dev       | dev         | None          |
| cd-test.yml | env/test      | test        | 1 reviewer    |
| cd-uat.yml  | env/uat       | uat         | 1 reviewer    |
| cd-prod.yml | main          | prod        | 2 reviewers   |

---

## Key Design Decisions

### Build Once, Deploy Many
A single immutable artifact (`build_<SHA>.zip`) is produced by CI and reused
identically in all four environments. This guarantees that exactly what was
tested in DEV and UAT is what lands in PROD.

### Immutable Artifact Naming
Artifacts are named by Git commit SHA. Any deployment is fully traceable
to an exact code state. Rollback means re-deploying a prior artifact by SHA.

### Expand/Contract for SQL
Schema migrations follow the Expand/Contract pattern to avoid downtime:
- **Phase 1 (Expand)**: add new columns alongside existing ones
- **Phase 2 (Migrate)**: backfill data
- **Phase 3 (Contract)**: drop old columns only after UAT sign-off

### Environment Isolation
Each environment has its own variable file (`cicd/variables/<env>.yml`) with
its own Azure resource names, connection strings, and log levels.
No configuration is shared between environments.

### Secrets in Azure Key Vault
All credentials are stored in Azure Key Vault.
No secrets are hardcoded in this repository.
The CI pipeline blocks any commit containing potential credentials (secret scan step).

---

## Rollback Strategy

| Level | Method | Time |
|-------|--------|------|
| Full rollback | Re-deploy prior artifact by SHA via CD workflow | ~5 min |
| ADF only | Feature flag in Azure App Configuration | Immediate |
| SQL schema | Drop new column (Expand/Contract Phase 1) | ~2 min |
| Infrastructure | Re-apply previous Bicep template | ~10 min |

---

## GitHub Settings

### Environments

| Environment | Reviewer(s) | Deployment branch |
|-------------|-------------|-------------------|
| dev         | None        | env/dev           |
| test        | M2joe       | env/test          |
| uat         | M2joe       | env/uat           |
| prod        | M2joe (x2)  | main              |

### Rulesets (Branch Protection)

| Ruleset              | Target     | Rules                                          |
|----------------------|------------|------------------------------------------------|
| protect-env-dev      | env/dev    | PR required, CI check, block force push        |
| protect-env-test     | env/test   | PR required, CI check, block force push        |
| protect-env-uat      | env/uat    | PR required, CI check, block force push        |
| protect-main-prod    | main       | PR required, CI check, block force push, up-to-date |

---

## Commit Convention

```
feat:      new feature
fix:       bug fix
chore:     maintenance (no functional change)
docs:      documentation only
ci:        CI/CD workflow change
refactor:  restructure without behaviour change
```

---

## Known Issue — CD-TEST Artifact Error

The `CD - Deploy to TEST #2` run failed with:
```
Unable to download artifact: build_b865ddac...
```

Root cause: `workflow_run` fires for any CI completion. When two CI runs
complete close together (e.g. env/dev and env/test), the `run-id` used to
download the artifact can reference the wrong CI run.

Fix: ensure the branch filter in `cd-test.yml` is strict and that the
artifact name matches exactly the SHA from the triggering CI run on `env/test`.
