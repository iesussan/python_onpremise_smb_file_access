# VARIABLES DE ENTORNO
export RESOURCE_GROUP_NAME="naranjax_poc"
export LOCATION="eastus2"
export VNET_NAME="naranjax-vnet"
export VNET_ADDRESS_SPACE="10.0.0.0/16"
export VNET_SUBNET_VM_WINDOWS_NAME="naranjax-vm-windows"
export VNET_SUBNET_VM_WINDOWS_ADDRESS_SPACE="10.0.0.0/24"

export VIRTUAL_MACHINE_NAME="naxvmwindows01"
export VIRTUAL_MACHINE_IMAGE="Win2019Datacenter"
export VIRTUAL_MACHINE_USERNAME="adminuser"
export VIRTUAL_MACHINE_PASSWORD='P@ssw0rd1234!'

export BASTION_NAME="naranjax-bastion"
export BASTION_IP_NAME="naranjax-bastion-ip"
export BASTION_IP_PUBLIC_SKU="Standard"
export BASTION_IP_PUBLIC_ALLOCATION_NAME="Static"

export NSG_NAME="naranjax-nsg"

# Crear grupo de recursos
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# Crear red virtual y subred
az network vnet create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $VNET_NAME \
  --address-prefix $VNET_ADDRESS_SPACE \
  --subnet-name $VNET_SUBNET_VM_WINDOWS_NAME \
  --subnet-prefix $VNET_SUBNET_VM_WINDOWS_ADDRESS_SPACE

# Crear NSG
az network nsg create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $NSG_NAME \
  --location $LOCATION

# Crear regla NSG para permitir conexiones desde 10.0.2.0/24 al puerto 445
az network nsg rule create \
  --resource-group $RESOURCE_GROUP_NAME \
  --nsg-name $NSG_NAME \
  --name Allow445From10.0.2.0-24 \
  --priority 1000 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes 10.0.2.0/24 \
  --source-port-ranges "*" \
  --destination-address-prefixes "*" \
  --destination-port-ranges 445

# Asociar NSG con la subred
az network vnet subnet update \
  --resource-group $RESOURCE_GROUP_NAME \
  --vnet-name $VNET_NAME \
  --name $VNET_SUBNET_VM_WINDOWS_NAME \
  --network-security-group $NSG_NAME

# Crear máquina virtual
az vm create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $VIRTUAL_MACHINE_NAME \
  --image $VIRTUAL_MACHINE_IMAGE \
  --admin-username $VIRTUAL_MACHINE_USERNAME \
  --admin-password $VIRTUAL_MACHINE_PASSWORD \
  --vnet-name $VNET_NAME \
  --subnet $VNET_SUBNET_VM_WINDOWS_NAME \
  --public-ip-address "" \
  --nsg ""  # El NSG ya está asociado a la subred

# Crear IP pública para Bastion
az network public-ip create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $BASTION_IP_NAME \
  --sku $BASTION_IP_PUBLIC_SKU \
  --allocation-method $BASTION_IP_PUBLIC_ALLOCATION_NAME

# Crear subred para Bastion
az network vnet subnet create \
  --resource-group $RESOURCE_GROUP_NAME \
  --vnet-name $VNET_NAME \
  --name AzureBastionSubnet \
  --address-prefixes 10.0.1.0/24

# Crear Bastion
az network bastion create \
  --name $BASTION_NAME \
  --public-ip-address $BASTION_IP_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --vnet-name $VNET_NAME \
  --location $LOCATION