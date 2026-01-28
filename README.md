# CI/CD Templates

Centralized repository containing reusable GitHub Actions workflows for the DevOps project ecosystem.

## Available Workflows

| Workflow | Description | Used By |
|----------|-------------|---------|
| [java-ci-full.yml](.github/workflows/java-ci-full.yml) | Complete CI pipeline for Java apps | `adrian-java-app` |
| [promote-environment.yml](.github/workflows/promote-environment.yml) | Promote app between environments | `infrastructure-env-*` |
| [validate-manifests.yml](.github/workflows/validate-manifests.yml) | Validate Kubernetes manifests | `infrastructure-env-prod` |

---

## java-ci-full.yml

Full CI pipeline for Java Spring Boot applications:

- Build and test with Maven
- SonarQube code quality analysis
- Docker image build and push to ACR
- Trivy security scan
- SBOM generation and Dependency-Track upload
- GitHub Release creation
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

## Related Repositories

| Repository | Purpose |
|------------|---------|
| `adrian-java-app` | Java Spring Boot Application |
| `infrastructure-env-dev` | DEV environment configuration |
| `infrastructure-env-test` | TEST environment configuration |
| `infrastructure-env-prod` | PROD environment configuration |