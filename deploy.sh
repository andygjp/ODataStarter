#!/bin/bash

resourceLocation="UK South"
resource="17eceb10e41c48fea08372a6b606ade4"
apiImage="api"
apiRepositoryImage="$resource.azurecr.io/$apiImage"
buildRuntime="linux-x64"
servicePlanSku="B1"

az group create --name $resource --location "$resourceLocation"

az acr create --name $resource \
    --resource-group $resource \
    --sku Basic \
    --admin-enabled true

az acr login --name $resource

docker build --build-arg BUILD_RUNTIME="$buildRuntime" \
    --no-cache=true \
    -t build \
    -f ./Dockerfile .

docker image tag build "${apiRepositoryImage}:latest"

docker push --all-tags "$apiRepositoryImage"

az appservice plan create --name "$resource" \
    --resource-group "$resource" \
    --sku "$servicePlanSku" \
    --is-linux

az webapp create --name "$resource" \
    --resource-group "$resource" \
    --plan "$resource" \
    --https-only true \
    --container-image-name "${apiRepositoryImage}:latest" \
    --acr-use-identity \
    --acr-identity [system] \
    --assign-identity [system]

az webapp log config --name "$resource" \
    --resource-group "$resource" \
    --detailed-error-messages true \
    --level verbose \
    --application-logging filesystem \
    --docker-container-logging filesystem

az webapp config appsettings set --name "$resource" \
    --resource-group "$resource" \
    --settings "WEBSITES_PORT=8080"

principalId=$(az webapp identity show --name "$resource" \
    --resource-group "$resource" \
    --query principalId \
    --output tsv)

registryId=$(az acr show --name "$resource" \
    --resource-group "$resource" \
    --query id \
    --output tsv)

az role assignment create --assignee "$principalId" \
    --scope "$registryId" \
    --role AcrPull