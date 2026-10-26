# 1. Create directory hierarchy
mkdir -p \
  .github/workflows \
  bootstrap \
  modules/governance \
  modules/networking-hub-spoke \
  modules/data-enclave \
  modules/workload-aca \
  environments/dev \
  environments/prod \
  scripts \
  docs/architecture

# 2. Create standard Terraform files (main, variables, outputs) across all modules
for mod in governance networking-hub-spoke data-enclave workload-aca; do
  touch "modules/${mod}/main.tf" \
        "modules/${mod}/variables.tf" \
        "modules/${mod}/outputs.tf"
done

# 3. Create environment files (dev and prod)
for env in dev prod; do
  touch "environments/${env}/backend.tf" \
        "environments/${env}/providers.tf" \
        "environments/${env}/main.tf" \
        "environments/${env}/variables.tf" \
        "environments/${env}/outputs.tf" \
        "environments/${env}/${env}.tfvars"
done

# 4. Create bootstrap, CI/CD, validation scripts, and root automation files
touch \
  bootstrap/main.tf \
  bootstrap/variables.tf \
  bootstrap/outputs.tf \
  .github/workflows/ci-validate-sec.yml \
  .github/workflows/nightly-finops-destroy.yml \
  scripts/verify-zero-trust.sh \
  Makefile \
  .gitignore \
  README.md
