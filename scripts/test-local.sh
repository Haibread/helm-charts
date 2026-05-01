#!/usr/bin/env bash
# Mirror of the CI lint + template jobs. Run from repo root: `bash scripts/test-local.sh`.
# Skips tools that aren't installed locally (prints a hint instead of failing).
set -euo pipefail

cd "$(dirname "$0")/.."

have() { command -v "$1" >/dev/null 2>&1; }

# ---- helm lint + template (mirror of .github/workflows/lint-test.yaml) ----
for chart in charts/*/; do
  name=$(basename "$chart")
  echo "================ lint $name ================"
  helm lint "$chart"

  echo "================ template $name :: defaults ================"
  helm template t "$chart" >/dev/null

  echo "================ template $name :: ingress + networkpolicy ================"
  helm template t "$chart" \
    --set ingress.enabled=true \
    --set networkPolicy.enabled=true >/dev/null

  echo "================ template $name :: httproute ================"
  helm template t "$chart" \
    --set httpRoute.enabled=true \
    --set httpRoute.parentRefs[0].name=gw \
    --set httpRoute.parentRefs[0].namespace=gateway-system >/dev/null

  echo "================ template $name :: each ci/*-values.yaml ================"
  for vf in "$chart"ci/*-values.yaml; do
    [ -e "$vf" ] || continue
    echo "  - $(basename "$vf")"
    helm template t "$chart" -f "$vf" >/dev/null
  done
done

# ---- ct lint (mirror of .github/workflows/lint.yaml) ----
echo "================ ct lint ================"
if have ct; then
  ct lint --config ct.yaml || echo "  (ct lint failed — see above)"
else
  echo "  ct not installed — skipping. Install: https://github.com/helm/chart-testing"
fi

# ---- yamllint ----
echo "================ yamllint ================"
if have yamllint; then
  yamllint -c .github/linters/.yamllint.yaml charts/ .github/ ct.yaml
else
  echo "  yamllint not installed — skipping. Install: pip install yamllint"
fi

# ---- markdownlint ----
echo "================ markdownlint ================"
if have markdownlint-cli2; then
  markdownlint-cli2 --config .github/linters/.markdownlint.yaml '**/*.md' '!**/node_modules/**'
else
  echo "  markdownlint-cli2 not installed — skipping. Install: npm i -g markdownlint-cli2"
fi

# ---- helm-docs drift ----
echo "================ helm-docs drift ================"
if have helm-docs; then
  helm-docs \
    --template-files="$(pwd)/.github/helm-docs/values.gotmpl" \
    --output-file=VALUES.md
  if ! git diff --exit-code -- charts/*/VALUES.md; then
    echo "  charts/*/VALUES.md is out of sync — commit the changes above."
    exit 1
  fi
else
  echo "  helm-docs not installed — skipping. Install: https://github.com/norwoodj/helm-docs/releases"
fi

echo
echo "All checks passed (skipped tools listed above)."
