#!/usr/bin/bash

#-------------------------------------------------
#DOCKER CI (ACR PUSH)
#-------------------------------------------------

APP_NAME="gha-docker-ci"
SUB_ID=$(az account show --query id --output tsv)

echo "creating azure ad app..."
APP_ID=$(az ad app create --display-name "$APP_NAME" --query appId --output tsv)

echo "creating Service principal..."
az ad sp create --id "$APP_ID" --output none

echo "Assigning Subscription Reader..."
az role assignment create --assignee "$APP_ID" --role "Reader" --scope /subscriptions/"$SUB_ID" --output none

echo "Assigning RBAC..."
az role assignment create --assignee "$APP_ID" --role AcrPush --scope /subscriptions/"$SUB_ID"/resourceGroups/passwordapp-rg/providers/Microsoft.ContainerRegistry/registries/passwordapp --output none

#-------------------------------------------------
#AKS ACR PULL
#-------------------------------------------------

echo "creating RBAC for AKS to pull ACR..."

AKS_OBJ_ID=$(az aks show -g passwordapp-rg -n passwordapp-aks --query identityProfile.kubeletidentity.objectId --output tsv)

ACR_ID=$(az acr show -g passwordapp-rg -n passwordapp --query id --output tsv)

echo "creating Role assignment for AKS to pull ACR..."
az role assignment create --assignee "$AKS_OBJ_ID" --role AcrPull --scope "$ACR_ID" --output none


FED_PARAMS=$(cat <<EOF
{
    "name": "docker-ci-main-only",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:OpsTrail/demo-password-app:ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"]
}
EOF
)

echo "creating Federated Credential..."
az ad app federated-credential create --id "$APP_ID" --parameters "$FED_PARAMS" --output none

echo "CLIENT_ID=$APP_ID"



