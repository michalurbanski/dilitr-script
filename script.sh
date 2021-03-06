#!/bin/bash

# Script deletes / scales down Azure resources.

# Logic:
# - Remove deletion locks
# - Remove vnet integration from App Services and Function Apps
# - Delete App Services and Function Apps
# - Delete App Service Plans (implicitly, when App Services and Function Apps are deleted)

RESOURCE_GROUP="$1"
if [ -z "$RESOURCE_GROUP" ]; then
    echo "Please provide resource group name as parameter"
    echo "Usage: ./script.sh resource_group_name"
    exit 1
fi

GREEN="\033[32m"
NOCOLOR="\033[0m"

# To avoid executing in a wrong subscription, ask user to confirm
echo "Currently selected subscription is:"
az account show

read -p "Do you want to remove resources in this subscription? ('yes' to continue): " confirmation # -p is prompt in the same line
if [[ "$confirmation" != "yes" ]]; then
    exit 2
fi

# locks=$(az lock list --resource-group $RESOURCE_GROUP --query "[].[id,name]" --output tsv)
locks=$(az lock list --resource-group $RESOURCE_GROUP --query "[].id" --output tsv)
for id in $locks
do
    # echo "id: $id"
    # TODO: use multiple ids in one go
    echo "Deleting lock: $id"
    az lock delete --ids $id
done
echo "All locks deleted."


webapps=$(az webapp list --resource-group $RESOURCE_GROUP --query "[].name" --output tsv)
for web in $webapps
do
    echo "Removing vnet integration for $web"
    az webapp vnet-integration remove --resource-group $RESOURCE_GROUP --name $web
    echo "Vnet integration removed for $web"
done
echo "All vnet integrations removed for App Services."


functionapps=$(az functionapp list --resource-group $RESOURCE_GROUP --query "[].name" --output tsv)
for fun in $functionapps
do
    echo "Removing vnet integration for $fun"
    az functionapp vnet-integration remove --resource-group $RESOURCE_GROUP --name $fun
    echo "Vnet integration removed for $fun"
done
echo "All vnet integrations removed for Function Apps."


for web in $webapps
do
    echo "Deleting App Service $web"
    az webapp delete --resource-group $RESOURCE_GROUP --name $web
    echo "App Service deleted $web"
done
echo "All App Services deleted."


for fun in $functionapps
do
    echo "Deleting Function App $fun"
    az functionapp delete --resource-group $RESOURCE_GROUP --name $fun
    echo "Function App deleted $fun"
done
echo "All Function Apps deleted."

echo -e "${GREEN}All done${NOCOLOR}"
