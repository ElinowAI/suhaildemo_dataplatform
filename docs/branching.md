# Branching Strategy — Suhail Data Platform

## Branch Model

```
feature/* --> env/dev --> env/test --> env/uat --> main
              (auto)     (1 appr)    (1 appr)   (2 appr)
```

## Branch Definitions

| Branch     | Purpose                  | Gate                              |
|------------|--------------------------|-----------------------------------|
| main       | Production — source of truth | 2 approvals + CI check        |
| env/uat    | Business validation      | 1 approval + CI check             |
| env/test   | Integration testing      | 1 approval + CI check             |
| env/dev    | Continuous integration   | PR required + CI check            |
| feature/*  | Feature development      | None — auto-deleted after merge   |

## Developer Workflow

```bash
# 1. Create feature branch from env/dev
git checkout env/dev && git pull origin env/dev
git checkout -b feature/my-feature

# 2. Develop, commit, push
git add . && git commit -m "feat: my change"
git push origin feature/my-feature

# 3. Open PR feature/* --> env/dev
#    CI triggers automatically
#    After merge --> CD-DEV runs (automatic)

# 4. PR env/dev --> env/test   (1 reviewer --> CD-TEST)
# 5. PR env/test --> env/uat   (1 reviewer + business sign-off --> CD-UAT)
# 6. PR env/uat --> main       (2 reviewers + release runbook --> CD-PROD)
```

## GitHub Rulesets

| Ruleset              | Target     | Active Rules                                      |
|----------------------|------------|--------------------------------------------------|
| protect-env-dev      | env/dev    | PR required · CI check · Block force push        |
| protect-env-test     | env/test   | PR required · CI check · Block force push        |
| protect-env-uat      | env/uat    | PR required · CI check · Block force push        |
| protect-main-prod    | main       | PR required · CI check · Block force push · Up-to-date |

## Commit Message Convention

```
feat:      new feature
fix:       bug fix
chore:     maintenance (no functional change)
docs:      documentation only
ci:        CI/CD workflow change
refactor:  restructure without behaviour change
```
