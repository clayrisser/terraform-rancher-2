CWD := $(shell pwd)

.PHONY: all
all:

.PHONY: orch
orch: orch_init
	@cd orch && terraform apply
	@cd orch && python3 ../extract_private_key.py
	@cd orch && terraform taint tls_private_key.orch

.PHONY: orch_init
orch_init: orch/.terraform

.PHONY: init
init: orch/.terraform servers/.terraform

.PHONY: clean
clean:
	-@git clean -fXd

orch/.terraform:
	@cd orch && terraform init
	@cd $(CWD)
