#!/bin/bash

# Script deletes / scales down Azure resources.

# Logic:
# - Remove deletion locks
# - Remove vnet integration from App Services
# - Delete App Services

RESOURCE_GROUP="$1"

# locks=$(az lock list --resource-group $RESOURCE_GROUP --query "[].[id,name]" --output tsv)
locks=$(az lock list --resource-group $RESOURCE_GROUP --query "[].id" --output tsv)

for id in $locks
do
    # echo "id: $id"
    # TODO: use multiple ids in one go
    echo "Deleting lock: $id"
    az lock delete --ids $id
done

echo "All locks deleted"


webapps=$(az webapp list --resource-group $RESOURCE_GROUP --query "[].name" --output tsv)

for web in $webapps
do
    echo "Removing vnet integration for $web"
    az webapp vnet-integration remove --resource-group $RESOURCE_GROUP --name $web
    echo "Vnet integration removed for $web"
done

echo "All vnet integrations removed."
