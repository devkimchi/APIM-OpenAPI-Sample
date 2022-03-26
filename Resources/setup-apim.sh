#!/bin/bash

set -e

# Get artifacts from GitHub
urls=$(curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/devkimchi/APIM-OpenAPI-Sample/releases/latest | jq '.assets[] | { name: .name, url: .browser_download_url }')
ipzip=$(echo $urls | jq 'select(.name == "ip.zip") | .url' -r)
oopzip=$(echo $urls | jq 'select(.name == "oop.zip") | .url' -r)

# Deploy function apps
ipapp=$(az functionapp deploy -g rg-$RESOURCE_NAME -n fncapp-$RESOURCE_NAME-ip --src-url $ipzip --type zip)
oopapp=$(az functionapp deploy -g rg-$RESOURCE_NAME -n fncapp-$RESOURCE_NAME-ip --src-url $oopzip --type zip)

# Provision APIs to APIM
az deployment group create -n ApiManagement_Api -g rg-$RESOURCE_NAME -u https://raw.githubusercontent.com/devkimchi/APIM-OpenAPI-Sample/main/Resources/provision-apimanagementapi.bicep -p name=$RESOURCE_NAME

# Update app settings on function apps
iphostnames=https://apim-$RESOURCE_NAME.azure-api.net/azip,$(az functionapp config appsettings list -g rg-$RESOURCE_NAME -n fncapp-$RESOURCE_NAME-ip | jq '.[] | select(.name == "OpenApi__HostNames") | .value' -r)
oophostnames=https://apim-$RESOURCE_NAME.azure-api.net/azoop,$(az functionapp config appsettings list -g rg-$RESOURCE_NAME -n fncapp-$RESOURCE_NAME-oop | jq '.[] | select(.name == "OpenApi__HostNames") | .value' -r)

ipsettings=$(az functionapp config appsettings set -g rg-$RESOURCE_NAME -n fncapp-$RESOURCE_NAME-ip --settings OpenApi__HostNames=$iphostnames)
oopsettings=$(az functionapp config appsettings set -g rg-$RESOURCE_NAME -n fncapp-$RESOURCE_NAME-oop --settings OpenApi__HostNames=$oophostnames)
