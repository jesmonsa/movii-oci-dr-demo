.PHONY: help init fmt validate plan apply primary destroy output

help:
	@echo "init     - terraform init"
	@echo "fmt      - terraform fmt -recursive"
	@echo "validate - terraform validate"
	@echo "plan     - terraform plan"
	@echo "apply    - terraform apply"
	@echo "primary  - apply solo region principal (deploy_standby=false)"
	@echo "destroy  - terraform destroy"
	@echo "output   - terraform output"

init:
	terraform init

fmt:
	terraform fmt -recursive

validate:
	terraform validate

plan:
	terraform plan

apply:
	terraform apply

primary:
	terraform apply -var="deploy_standby=false"

destroy:
	terraform destroy

output:
	terraform output
