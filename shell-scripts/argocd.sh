#!/usr/bin/bash

APP_NAME="gha-argocd-bootstrap"
SUB_ID=$(az account show --query id --output tsv)

echo "creating azure ad app..."
APP_ID=$(az ad app create --display-name "$APP_NAME" --query appId --output tsv)

echo "creating Service principal..."
az ad sp create --id "$APP_ID" --output none

echo "Assigning Subscription Reader..."
az role assignment create --assignee "$APP_ID" --role "Reader" --scope /subscriptions/"$SUB_ID" --output none

echo "Assigning RBAC..."
az role assignment create --assignee "$APP_ID" --role "Azure Kubernetes Service Cluster User Role" --scope /subscriptions/"$SUB_ID"/resourceGroups/passwordapp-rg/providers/Microsoft.ContainerService/managedClusters/passwordapp-aks --output none

FED_PARAMS=$(cat <<EOF
{
    "name": "argocd-bootstrap-main-only",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:OpsTrail/demo-password-app:ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"]
}
EOF
)

echo "creating Federated Credential..."
az ad app federated-credential create --id "$APP_ID" --parameters "$FED_PARAMS" --output none

echo "CLIENT_ID=$APP_ID"