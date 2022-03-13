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
