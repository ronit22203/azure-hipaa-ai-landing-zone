.PHONY: help fmt validate sec-scan bootstrap-init bootstrap-apply \
	dev-init dev-plan dev-up dev-bastion-up dev-down verify

.DEFAULT_GOAL := help

ENV ?= dev
TF_DIR = environments/$(ENV)

##@ General
help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} \
		/^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2 } \
		/^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) }' $(MAKEFILE_LIST)

##@ Code Quality & Static Security (Free / Local)
fmt: ## Format all Terraform files recursively
	terraform fmt -recursive

validate: fmt ## Validate syntax across environment
	cd $(TF_DIR) && terraform init -backend=false && terraform validate

sec-scan: ## Run Checkov static analysis against Terraform code
	checkov -d . --framework terraform --compact --quiet

##@ Step 0: Remote State Bootstrap (One-Time Setup, ~$0.02/mo)
bootstrap-init: ## Initialize bootstrap Terraform
	cd bootstrap && terraform init

bootstrap-apply: ## Create remote state storage (~$0.02/mo)
	cd bootstrap && terraform apply -auto-approve

##@ Ephemeral Lab Lifecycle (Shoestring Mode)
dev-init: ## Initialize dev backend with remote Azure Storage state
	cd environments/dev && terraform init

dev-plan: ## Preview infrastructure changes
	cd environments/dev && terraform plan -var-file="dev.tfvars" -out="dev.tfplan"

dev-up: ## Spin up the HIPAA Landing Zone (~3 mins)
	cd environments/dev && terraform apply -var-file="dev.tfvars" -auto-approve

dev-bastion-up: ## Temporarily enable Azure Bastion ($0.19/hr) for SSH lab testing
	cd environments/dev && terraform apply -var-file="dev.tfvars" -var="deploy_bastion=true" -auto-approve

dev-down: ## Destroy all billable resources immediately ($0.00/hr run rate)
	cd environments/dev && terraform destroy -var-file="dev.tfvars" -auto-approve

##@ Verification
verify: ## Run external network isolation tests against deployed endpoints
	./scripts/verify-zero-trust.sh
