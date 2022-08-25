# Deploying Azure Logic Apps using IaC

This repository contains a demo to illustrate a blog post about the deployment of Azure Logic Apps using IaC.  
The demo consists in a Logic App triggered by HTTP to append a line in a Storage Table. All resources can be deployed using either Bicep or Terraform.


## Prerequisites

To run the code from this repo you will need the following requirements:
- An Azure subscription with owner access
- Azure and Bicep CLIs if you plan to use Bicep (I have versions 2.39.0 and 0.9.1)
- Terraform CLI if you plan to use Terraform (I have version 1.2.7)
- A shell (any shell will do, I have used Zsh in WSL)


## Getting started

### Using Bicep
From the root of the cloned repo, use the following command to create the Azure resources:
```shell
az deployment sub create -l $AZURE_LOCATION --template-file bicep/main.bicep
```
You can set the `$AZURE_LOCATION` with the Azure region of your choice, I have used `francecentral` as it's the closest of my current location.

### Using Terraform
From the `terraform` folder of the cloned repo, use the following command to create the Azure resources:
```shell
terraform apply -auto-approve -var location=$AZURE_LOCATION
```
You can set the `$AZURE_LOCATION` with the Azure region of your choice, I have used `francecentral` as it's the closest of my current location.


## Check that everything is working fine

Once the deployment is complete the best way to check is to run the Logic App from the Azure portal, and use the storage explorer (still from the Azure portal) from the Storage Account blade to check the content of the Azure Table.  
