# Azure DevOps Environment Deployment

This project automates the deployment of a complete Azure DevOps environment, including infrastructure setup and application deployment. 
It consists of a main deployment script (`createInfra_build_and_deploy.sh`) and two core directories: `azureDevInfra` (infrastructure code) and `azureApp` (application services).

## Overview

The deployment process consists of three main stages:

1. **Infrastructure Creation** - Uses Terraform to create the Azure DevOps environment
2. **Repository Setup** - Pushes infrastructure and application code to Azure repos
3. **CI/CD Pipeline Execution** - Triggers the initial pipeline deployment

### Application Components

The application consists of three services:
- API Service
- Frontend Service
- Database Service

All services are containerized and deployed to Kubernetes using Azure DevOps pipelines.

## Prerequisites

### Required Tools
- Azure CLI ([**Installation Guide**](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli))
- Terraform CLI ([**Installation Guide**](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli))

### Account Setup
1. Create an [**Azure Account**](https://azure.microsoft.com/en-us/pricing/purchase-options/azure-account) (Pay as you go)
2. Set up an [**Azure DevOps Organization**](https://learn.microsoft.com/en-us/azure/devops/organizations/accounts/create-organization?view=azure-devops#create-an-organization-1)
3. Generate an [**Azure DevOps PAT**](https://learn.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=Windows#create-a-pat)
4. Configure [**parallel jobs**](https://learn.microsoft.com/en-us/azure/devops/pipelines/licensing/concurrent-jobs?view=azure-devops&tabs=ms-hosted#how-do-i-buy-more-parallel-jobs) (minimum 3) in Azure DevOps

## Configuration

### Update terraform.tfvars
```hcl
### Microsoft Azure ###
azure_subscription_name = "Azure subscription 1"  
azure_subscription_id   = "your-subscription-id"
azure_tenant_id        = "your-tenant-id"

### Geo Location ###
location               = "West Europe"

### Azure DevOps ###
username              = "YourUsername"
azuredevops_pat       = "your-pat-token"
```

### Update createInfra_build_and_deploy.sh
```bash
# Variables
ORGANIZATION="your-org-name"
PAT="your-pat-token"
APP="azureApp"
INFRA="azureDevInfra"
PIPELINE_NAME="buildazureApp"
AZURE_ORG_URL="https://dev.azure.com/your-org-name"
PROJECT="azureDevProject"
APP_REPO_URL="https://$ORGANIZATION:$PAT@dev.azure.com/your-org-name/azureDevProject/_git/azureApp"
TERRAFORM_REPO_URL="https://$ORGANIZATION:$PAT@dev.azure.com/your-org-name/azureDevProject/_git/azureDevInfra"
```

## Terraform Structure
```
.
├── main.tf                # Root Terraform configuration
├── variables.tf           # Root-level variables
├── outputs.tf            # Root-level outputs
└── modules/              # Terraform modules
    ├── azure-devops/    # Azure DevOps resources
    ├── acr/             # Azure Container Registry
    ├── aks/             # Azure Kubernetes Service
    ├── ci-pipeline/     # CI pipeline configuration
```

### Terraform Modules Descriptions

- **azure-devops**: Creates Azure DevOps infrastructure, repositories, and generates Git credentials
- **acr**: Provisions Azure Container Registry
- **aks**: Sets up Azure Kubernetes Service cluster
- **ci-pipeline**: Manages CI/CD pipeline

## Deploy the project
1. **Clone Project**
```bash
git clone https://your-org-name@dev.azure.com/your-org-name/azureDevProject/_git/azureDevInfra
cd terraform_azure_devops_kit
```
2. **Authenticate with Azure:**
```bash
az login
```
3. **Execute the bash script:**
```bash
./createInfra_build_and_deploy.sh
```
4. **Connect to Application Frontend:**
- Get the external IP for the Application out of the K8s Logs (See frontend logs) and you should be able to connect over HTTPS.

## Best Practices
- Use remote state storage for Terraform state files
- Implement separate workspaces for different environments (dev/staging/prod)

## Contributing
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/enhancement`)
3. Commit changes (`git commit -m 'Add new feature'`)
4. Push to branch (`git push origin feature/enhancement`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
