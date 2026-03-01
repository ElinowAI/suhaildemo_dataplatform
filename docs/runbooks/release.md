# Release Runbook — Suhail Data Platform

Complete this checklist before every PROD deployment.

## Pre-Release

- [ ] UAT deployment successful
- [ ] Business stakeholder sign-off obtained
- [ ] No open critical bugs
- [ ] Artifact SHA identified: ________________________________
- [ ] Same artifact validated: CI + DEV + TEST + UAT
- [ ] Reviewer 1 approved PR: ________________
- [ ] Reviewer 2 approved PR: ________________

## Deployment Steps

1. Merge release PR (env/uat --> main) on GitHub
2. Monitor CD - Deploy to PROD in the Actions tab
3. Confirm all steps complete with green checkmarks

## Post-Deploy Validation

- [ ] Smoke tests passed in the CD-PROD workflow run
- [ ] ADF pipeline pl_demo_copy visible and healthy
- [ ] SQL tables raw.sales_transactions and silver.sales_daily_summary accessible
- [ ] Power BI report sales_daily_report loads correctly

## Sign-Off

| Field         | Value |
|---------------|-------|
| Release date  |       |
| Artifact SHA  |       |
| Released by   |       |
| Approver 1    |       |
| Approver 2    |       |
| Workflow URL  |       |
