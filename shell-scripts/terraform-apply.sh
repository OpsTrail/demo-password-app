#!/usr/bin/bash

APP_NAME="gha-terraform-apply"
SUB_ID=$(az account show --query id --output tsv)

echo "creating azure ad app..."
APP_ID=$(az ad app create --display-name "$APP_NAME" --query appId --output tsv)

echo "creating Service principal..."
az ad sp create --id "$APP_ID" --output none

echo "Assigning RBAC..."

az role assignment create --assignee "$APP_ID" --role Contributor --scope "/subscriptions/$SUB_ID" --output none

echo "Assigning RBAC for Blob Storage..."
az role assignment create --assignee "$APP_ID" --role "Storage Blob Data Contributor" --scope /subscriptions/$SUB_ID/resourceGroups/tfstate-rg --output none


FED_PARAMS=$(cat <<EOF
{
    "name": "tf-apply-main-only",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:OpsTrail/demo-password-app:ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"]
}
EOF
)

echo "creating Federated Credential..."
az ad app federated-credential create --id "$APP_ID" --parameters "$FED_PARAMS" --output none

echo "CLIENT_ID=$APP_ID"