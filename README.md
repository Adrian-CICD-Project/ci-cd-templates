# CI/CD Templates

Centralized repository containing reusable GitHub Actions workflows for the DevOps project ecosystem.

## Available Workflows

| Workflow | Description | Used By |
|----------|-------------|---------|
| [java-ci-full.yml](.github/workflows/java-ci-full.yml) | Complete CI pipeline for Java apps | `adrian-java-app` |
| [promote-environment.yml](.github/workflows/promote-environment.yml) | Promote app between environments | `infrastructure-env-*` |
| [validate-manifests.yml](.github/workflows/validate-manifests.yml) | Validate Kubernetes manifests | `infrastructure-env-prod` |
| [gitleaks.yml](.github/workflows/gitleaks.yml) | Secret scanning (full git history) | all repositories |
| [terraform-ci.yml](.github/workflows/terraform-ci.yml) | Terraform fmt/validate + Checkov | `infra-azure`, `infra-aws`, `infra-gcp` |

---

## java-ci-full.yml

Full CI pipeline for Java Spring Boot applications:

- Build and test with Maven
- SonarQube code quality analysis
- Docker image build; push to ACR **only from `main`** (feature branches build-only)
- Trivy security scan with gate — pipeline fails on fixable CRITICAL vulnerabilities
- SBOM generation, Dependency-Track upload and findings export
- GitHub Release creation with assets: SBOM, Dependency-Track findings, Trivy report, JUnit results
- Automatic promotion to DEV environment

**Usage:**

```yaml
jobs:
  pipeline:
    uses: Adrian-CICD-Project/ci-cd-templates/.github/workflows/java-ci-full.yml@main
    with:
      image-name: my-app
      env-repo: org/infrastructure-env-dev
    secrets: inherit
```

---

## promote-environment.yml

Universal workflow for promoting applications between environments (dev → test, test → prod):

- Extracts image tag from source environment
- Updates values.yaml and deployment.yaml in target environment
- Creates Pull Request to target repository

**Usage:**

```yaml
jobs:
  promote:
    uses: Adrian-CICD-Project/ci-cd-templates/.github/workflows/promote-environment.yml@main
    with:
      app-name: adrian-java-app
      source-env: dev
      target-env: test
      target-repo: org/infrastructure-env-test
      acr-repo: myacr.azurecr.io/adrian-java-app
    secrets: inherit
```

---

## validate-manifests.yml

Validates Kubernetes manifest YAML syntax:

**Usage:**

```yaml
jobs:
  validate:
    uses: Adrian-CICD-Project/ci-cd-templates/.github/workflows/validate-manifests.yml@main
    with:
      app-name: adrian-java-app
```

---

## gitleaks.yml

Scans the full git history for committed secrets (gitleaks, `--redact` so no secret
values appear in CI logs). Wired into every repository in the organization.

**Usage:**

```yaml
on:
  push:
  pull_request:

jobs:
  gitleaks:
    uses: Adrian-CICD-Project/ci-cd-templates/.github/workflows/gitleaks.yml@main
```

---

## terraform-ci.yml

CI for Terraform repositories: `terraform fmt -check` → `init -backend=false` →
`validate`, plus an informational Checkov security scan (`soft_fail`).

**Usage:**

```yaml
jobs:
  terraform:
    uses: Adrian-CICD-Project/ci-cd-templates/.github/workflows/terraform-ci.yml@main
    with:
      working-directory: "."
```

---

## Scripts

| Script | Purpose |
|--------|---------|
| [scripts/setup-branch-protection.sh](scripts/setup-branch-protection.sh) | One-time branch protection setup for all org repos (merge via PR only, no force-push). Requires `gh` CLI with org admin rights. GitHub settings survive `terraform destroy`. |

---

## Related Repositories

| Repository | Purpose |
|------------|---------|
| `adrian-java-app` | Java Spring Boot Application |
| `infrastructure-env-dev` | DEV environment configuration |
| `infrastructure-env-test` | TEST environment configuration |
| `infrastructure-env-prod` | PROD environment configuration |

---

## Security Notes

- CI workflows do **not** log secrets or tokens to GitHub Actions output
- Workflow permissions follow least-privilege principle
- All sensitive data is managed via GitHub Secrets (CI) and Azure Key Vault (runtime)