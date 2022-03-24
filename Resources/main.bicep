param name string
param location string = resourceGroup().location
param suffixes array = [
    'ip'
    'oop'
]
param apiManagementPublisherName string
param apiManagementPublisherEmail string

module apim './provision-apimanagement.bicep' = {
    name: 'ApiManagement_main'
    params: {
        name: name
        location: location
        apiMgmtPublisherName: apiManagementPublisherName
        apiMgmtPublisherEmail: apiManagementPublisherEmail
    }
}

module fncapps './provision-functionapp.bicep' = [for suffix in suffixes: {
    name: 'FunctionApp_main_${suffix}'
    dependsOn: [
        apim
    ]
    params: {
        name: name
        suffix: suffix
        location: location
    }
}]
