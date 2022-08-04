#===============================================================================
#
# Terraform Makefile
#
#===============================================================================

#-------------------------------------------------------------------------------
# Configuration
#-------------------------------------------------------------------------------
vault_profile = cs-dev


#-------------------------------------------------------------------------------
# Local variables
#-------------------------------------------------------------------------------
vault_exec = aws-vault exec $(vault_profile) --
#tf = $(vault_exec) terraform
tf = terraform
ifc = $(vault_exec) infracost


#-------------------------------------------------------------------------------
# Pipeline targets
#-------------------------------------------------------------------------------
all: init validate checkov


#-------------------------------------------------------------------------------
# Other targets
#-------------------------------------------------------------------------------

# Terraform commands, run via aws-vault
apply:
	$(tf) apply
destroy:
	$(tf) destroy
init:
	$(tf) init
plan: validate
	$(tf) plan
validate:
	$(tf) validate


# Checkov static analysis
checkov:
	if [ -s .checkov.baseline ]; then \
  		make checkov_baseline; \
  	else \
  	  	make checkov_full; \
  	fi
checkov_full:
	checkov --quiet --compact --framework terraform --directory .
checkov_create_baseline:
	checkov --quiet --create-baseline --framework terraform --directory .
checkov_baseline:
	checkov --quiet --compact --framework terraform --baseline .checkov.baseline --directory .



# AWS Vault clear all session keys
clear:
	aws-vault clear


infracost-breakdown:
	$(ifc) breakdown --path .
infracost-diff:
	$(ifc) diff --path .

yor:
	yor tag -d .

# Developer tools
install_tools:
	# Asdf version manager must already be installed
	asdf plugin-add aws-vault
	asdf plugin-add yor
	asdf install
	pip install -U pip
	pip install -U checkov 
	asdf reshim
