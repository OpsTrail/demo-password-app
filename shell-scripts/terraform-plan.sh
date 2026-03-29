#!/usr/bin/bash

#-------------------------------------------------
#TERRAFORM Backend
#-------------------------------------------------

RG_NAME="tfstate-rg"
SA_NAME="passwordtfstate"
BLOB_CONTAINER="tfstate"
LOCATION="centralindia"

echo "creating respurce group..."
az group create --name "$RG_NAME" --location centralindia

echo "creating storage account for blob storage..."
az storage account create --name "$SA_NAME" --resource-group "$RG_NAME" --location "$LOCATION" --sku Standard_LRS --encryption-services blob --output none

echo "creating conatiner in blob..."
az storage container create --name "$BLOB_CONTAINER" --account-name "$SA_NAME" --auth-mode login --output none

#-------------------------------------------------
#TERRAFORM PLAN (READ-ONLY)
#-------------------------------------------------

APP_NAME="gha-terraform-plan"
SUB_ID=$(az account show --query id --output tsv)

echo "creating azure ad app..."
APP_ID=$(az ad app create --display-name "$APP_NAME" --query appId --output tsv)

echo "creating Service principal..."
az ad sp create --id "$APP_ID"

echo "Assigning RBAC..."
az role assignment create --assignee "$APP_ID" --role Reader --scope "/subscriptions/$SUB_ID" --output none

echo "Assigning RBAC for Blob Storage..."
az role assignment create --assignee "$APP_ID" --role "Storage Blob Data Contributor" --scope /subscriptions/$SUB_ID/resourceGroups/tfstate-rg --output none

FED_PARAMS=$(cat <<EOF
{
  "name": "terraform-update-branch",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:OpsTrail/demo-password-app:ref:refs/heads/terraform-update",
  "audiences": ["api://AzureADTokenExchange"]
}
EOF
)

echo "creating Federated Credential"
az ad app federated-credential create --id "$APP_ID" --parameters "$FED_PARAMS" --output none

echo "CLIENT_ID=$APP_ID"