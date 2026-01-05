infra-init:
	terraform init -reconfigure -backend-config config.aws.tfbackend

infra-apply:
	terraform fmt
	terraform validate
	terraform apply
	terraform output -json > outputs.json

test:
	./test.sh
