#!/bin/bash

# Variables
ORGANIZATION="azureDevOrg"
PAT="6y8hQbMSA1vjb5PP1aHzneX57Fql8lF5Z614CVinllStN9999999999999999999"
APP=azureApp
INFRA=azureDevInfra
PIPELINE_NAME="buildazureApp"
AZURE_ORG_URL="https://dev.azure.com/azureDevOrg"
PROJECT="azureDevProject"
APP_REPO_URL="https://$ORGANIZATION:$PAT@dev.azure.com/azureDevOrg/azureDevProject/_git/azureApp"
TERRAFORM_REPO_URL="https://$ORGANIZATION:$PAT@dev.azure.com/azureDevOrg/azureDevProject/_git/azureDevInfra"
ROOT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
APP_REPO="$ROOT_DIR/$APP"
TERRAFORM_REPO="$ROOT_DIR/$INFRA"


# Configure git to store credentials
git config --global credential.helper store
git config --global credential.helper 'cache --timeout=3600'

# Configure Azure DevOps defaults
az devops configure --defaults organization=$AZURE_ORG_URL

# Create Azure DevOps INFRA
cd azureDevInfra
terraform init
terraform plan -out=terraPlan
terraform apply -auto-approve terraPlan
cd -

# Create directories if they don't exist
mkdir -p "$APP_REPO"
mkdir -p "$TERRAFORM_REPO"

# Push to App repo
echo "Updating ACR ID in pipeline & Pushing code to azureApp..."
cd "$APP_REPO" || exit 1

# Get Docker Registry Service Connection ID
dockerRegistryServiceConnection=$(az devops service-endpoint list --project "$PROJECT" --query "[?type=='dockerregistry']" \
| grep -A1 "groupScopeId" | tail -1 | cut -d '"' -f4)

# sed editing (supporting both mac and linux OS)
case "$(uname -s)" in
    Darwin*)    # macOS
        sed -i '' "s/dockerRegistryServiceConnection: '[^']*'/dockerRegistryServiceConnection: '$dockerRegistryServiceConnection'/g" ci-pipeline.yml
        ;;
    Linux*)     # Linux
        sed -i "s/dockerRegistryServiceConnection: '[^']*'/dockerRegistryServiceConnection: '$dockerRegistryServiceConnection'/g" ci-pipeline.yml
        ;;
    *)
        echo "Unknown operating system"
        exit 1
        ;;
esac

# Push to azureApp
if [ -d "$APP_REPO/.git" ]; then
    # If .git exists, update remote and push
    git remote set-url origin "$APP_REPO_URL"
    git add .
    git commit -m "Update pipeline configuration" || true
    git push origin master
else
    # If .git doesn't exist, initialize new repo
    git init
    git remote add origin "$APP_REPO_URL"
    git add .
    git commit -m "Initial commit"
    git branch -M master
    git push -u origin master
fi

# Push to azureDevInfra
echo "Pushing code to Terraform IAC Repo"
cd "$TERRAFORM_REPO" || exit 1

if [ -d "$TERRAFORM_REPO/.git" ]; then
    # If .git exists, update remote and push
    git remote set-url origin "$TERRAFORM_REPO_URL"
    git add .
    git commit -m "Update infrastructure configuration" || true
    git push origin master
else
    # If .git doesn't exist, initialize new repo
    git init
    git remote add origin "$TERRAFORM_REPO_URL"
    git add .
    git commit -m "Initial commit"
    git branch -M master
    git push -u origin master
fi

# Trigger pipeline
echo "#########  Triggering pipeline $PIPELINE_NAME  ###########"
az pipelines run --name "$PIPELINE_NAME" --organization "$AZURE_ORG_URL" --project "$PROJECT"