# Makefile

init:
	terraform init -backend-config=".tfbackend" -reconfigure
	
plan: init
	terraform plan -var-file="terraform.tfvars"

apply: init
	terraform apply -var-file="terraform.tfvars"
