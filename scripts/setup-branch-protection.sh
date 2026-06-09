#!/bin/bash
set -e

# ============================================================
# Branch protection dla wszystkich repo w organizacji.
# Ustawienia GitHub przeżywają zaoranie infry Terraformem -
# skrypt uruchamia się JEDNORAZOWO (lub po zmianach w org).
#
# Wymaga: gh CLI zalogowane z uprawnieniami admin do org.
#   gh auth status
#
# Model solo-developer:
#  - merge tylko przez Pull Request (wymusza GitOps flow),
#  - wymagane przejście status checków CI,
#  - 0 wymaganych approvals (jednoosobowy projekt - autor
#    nie może zatwierdzić własnego PR),
#  - bez force-push i usuwania brancha main.
# ============================================================

ORG="Adrian-CICD-Project"

REPOS=(
  adrian-java-app
  ci-cd-templates
  infrastructure-env-dev
  infrastructure-env-test
  infrastructure-env-prod
  platform-apps
  infra-azure
  documentation
)

for REPO in "${REPOS[@]}"; do
  echo "→ ${ORG}/${REPO}: ustawiam branch protection na main..."

  gh api -X PUT "repos/${ORG}/${REPO}/branches/main/protection" \
    --input - <<'EOF' || { echo "  ⚠️  Pominięto (repo nie istnieje lub brak uprawnień)"; continue; }
{
  "required_status_checks": {
    "strict": false,
    "contexts": []
  },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "required_approving_review_count": 0
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
EOF

  echo "  ✓ OK"
done

echo ""
echo "Gotowe. Weryfikacja: gh api repos/${ORG}/<repo>/branches/main/protection"
echo ""
echo "Uwaga: po pierwszym przebiegu CI warto dodać nazwy checków do"
echo "required_status_checks.contexts (np. 'pipeline / build-test'),"
echo "żeby merge był możliwy tylko przy zielonym CI."
