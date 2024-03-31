steps to run

az login
az accounts show
az account set --subscription mct2

skrypt: https://raw.githubusercontent.com/zagruby/cka/main/script.sh

az deployment group create --name ExampleDeployment --resource-group vm1 --template-file vm.bicep --parameters '@vm.parameters.json'

az deployment group delete --name ExampleDeployment --resource-group vm1 