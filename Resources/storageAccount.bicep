param name string
param suffix string = ''
param location string = resourceGroup().location

@allowed([
    'Standard_LRS'
    'Standard_ZRS'
    'Standard_GRS'
    'Standard_GZRS'
    'Standard_RAGRS'
    'Standard_RAGZRS'
    'Premium_LRS'
    'Premium_ZRS'
])
param storageAccountSku string = 'Standard_LRS'

var storage = {
    name: 'st${replace(name, '-', '')}${suffix}'
    location: location
    sku: storageAccountSku
}

resource st 'Microsoft.Storage/storageAccounts@2021-06-01' = {
    name: storage.name
    location: storage.location
    kind: 'StorageV2'
    sku: {
        name: storage.sku
    }
    properties: {
        supportsHttpsTrafficOnly: true
    }
}

output id string = st.id
output name string = st.name
