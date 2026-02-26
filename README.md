# data-platform-cicd

Monorepo CI/CD repository to manage deployment of Data Platform assets 
(ADF / SQL / Power BI / Infrastructure) across four environments:

DEV → TEST → UAT → PROD

---

## Environments & Branch Mapping

| Branch     | Environment |
|------------|------------|
| env/dev    | DEV        |
| env/test   | TEST       |
| env/uat    | UAT        |
| main       | PROD       |

---

## Promotion Flow

feature/* → env/dev → env/test → env/uat → main

### Workflow Description

1. Developers create feature branches from `env/dev`
2. Pull Request into `env/dev` triggers automatic deployment to DEV
3. Promotion PR from:
   - `env/dev` → `env/test` triggers TEST deployment (approval required)
   - `env/test` → `env/uat` triggers UAT deployment (approval required)
   - `env/uat` → `main` triggers PROD deployment (double approval required)

---

## Repository Structure

- `infra/`   → Infrastructure as Code (Bicep/Terraform)
- `adf/`     → Azure Data Factory assets (pipelines, datasets, triggers)
- `sql/`     → dbt models / migrations / DACPAC
- `powerbi/` → Datasets, reports and deployment scripts
- `cicd/`    → CI/CD templates, variables, deployment scripts
- `docs/`    → Architecture documentation, branching strategy, runbooks

---

## CI/CD Workflows

### Continuous Integration (CI)
Triggered on Pull Requests:
- Code linting and formatting checks
- SQL/dbt validation tests
- ADF template validation
- Security scan (no hardcoded secrets)
- Build and publish versioned artifact

Artifact naming convention: