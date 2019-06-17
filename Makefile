API_URL=localhost
USER=testuser
DATE=2018-06-17

.PHONY: help
help:            ## Help for command list
	@echo ""
	@echo "Deploy and destroy mysql-lambda-apigateway stack on AWS"
	@echo "Before running export TF_VARS"
	@echo ""
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

.PHONY: deploy
deploy:          ## Deploy full stack
	@echo "Deploy all resources"
	./scripts/pipeline.sh


.PHONY: lambda_deploy
lambda_deploy:   ## Deploy only updated lambda functions
	@echo "lambda deploy"
	./scripts/lambda_deploy.sh

.PHONY: destroy 
destroy:         ## Destroy all resources
	@echo "destroy all"
	./scripts/destroy.sh
	

.PHONY: put_test
put_test:         ## Run api gateway sample tests - pass API_URL USER DATE vars
	@echo "PUT TEST RUNNNING....."
	curl -vvv -X PUT https://$(API_URL)/prod/hello/$(USER)?dateOfBirth=$(DATE)
	@echo ""


.PHONY: get_test
get_test:         ## Run api gateway sample tests - pass API_URL USER vars
	@echo "GET TEST RUNNNING....."
	curl -vvv https://$(API_URL)/prod/hello/$(USER)
	@echo ""
