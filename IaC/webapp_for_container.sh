export RESOURCE_GROUP_NAME="naranjax_poc"
export LOCATION="eastus2"
export VNET_NAME="naranjax-vnet"

export WEBAPP_FC_SUBNET_NAME="naranjax-webapp-fc-python"
export WEBAPP_FC_PLAN_NAME="naranjax-webapp-fc-plan"
export WEBAPP_FC_CONTAINER_NAME="naranjax-webapp-fc-python-container"
export AZURE_CONTAINER_REGISTRY_NAME="naranjaxacr"
export AZURE_CONTAINER_REGISTRY_SKU="Standard"

export WEBAPP_FC_CONTAINER_IMAGE_NAME="python-smb_access:0.2.26"

#create azure container registry with standard sku and admin enabled


az acr create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $AZURE_CONTAINER_REGISTRY_NAME \
  --sku $AZURE_CONTAINER_REGISTRY_SKU \
  --admin-enabled true

# Compilar y publicar la imagen en ACR
az acr build \
  --registry $AZURE_CONTAINER_REGISTRY_NAME \
  --image python-smb_access:0.2.26 \
  --file Dockerfile .

az appservice plan create \
  --name $WEBAPP_FC_PLAN_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --location $LOCATION \
  --is-linux \
  --sku P1V2

az appservice plan show \
  --name $WEBAPP_FC_PLAN_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --query "{Name:name, SKU:sku.name, Tier:sku.tier}" \
  --output table

az network vnet subnet create \
  --resource-group $RESOURCE_GROUP_NAME \
  --vnet-name $VNET_NAME \
  --name $WEBAPP_FC_SUBNET_NAME \
  --address-prefix 10.0.2.0/24

subnet_id=$(az network vnet subnet show \
  --resource-group $RESOURCE_GROUP_NAME \
  --vnet-name $VNET_NAME \
  --name $WEBAPP_FC_SUBNET_NAME \
  --query id -o tsv)

az webapp create \
    --resource-group $RESOURCE_GROUP_NAME \
    --plan $WEBAPP_FC_PLAN_NAME \
    --name $WEBAPP_FC_CONTAINER_NAME \
    --container-image-name "naranjaxacr.azurecr.io/python-smb_access:0.2.26" \
    --assign-identity "[system]" \
    --acr-identity "[system]"


#bring permission to managed identity to pull image from acr using az role assignment
acr_id=$(az acr show --name $AZURE_CONTAINER_REGISTRY_NAME --resource-group $RESOURCE_GROUP_NAME --query id --output tsv) 
principal_id=$(az webapp identity show --name $WEBAPP_FC_CONTAINER_NAME --resource-group $RESOURCE_GROUP_NAME --query principalId --output tsv)
az role assignment create --assignee $principal_id --role acrpull --scope $acr_id


Webapp_Config=$(az webapp show -g $RESOURCE_GROUP_NAME -n $WEBAPP_FC_CONTAINER_NAME --query id --output tsv)"/config/web"
az resource update --ids $Webapp_Config --set properties.acrUseManagedIdentityCreds=True -o none

# Integrar con la VNet (si es necesario)
az webapp vnet-integration add \
  --name $WEBAPP_FC_CONTAINER_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --vnet $VNET_NAME \
  --subnet $WEBAPP_FC_SUBNET_NAME

az webapp config appsettings set \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $WEBAPP_FC_CONTAINER_NAME \
  --settings \
    SMB_SERVER="10.0.0.6" \
    SMB_USERNAME="adminuser" \
    SMB_PASSWORD='P@ssw0rd1234!' \
    SMB_SHARE='shared_access' \
    SMB_FILE_PATH='test.txt'

az webapp restart \
  --name $WEBAPP_FC_CONTAINER_NAME \
  --resource-group $RESOURCE_GROUP_NAME

az webapp log tail \
  --name $WEBAPP_FC_CONTAINER_NAME \
  --resource-group $RESOURCE_GROUP_NAME

az webapp delete \
  --name $WEBAPP_FC_CONTAINER_NAME \
  --resource-group $RESOURCE_GROUP_NAME