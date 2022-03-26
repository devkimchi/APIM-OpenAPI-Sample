param name string
param location string = resourceGroup().location
param suffixes array = [
    'ip'
    'oop'
]
param apiManagementPublisherName string
param apiManagementPublisherEmail string
param functionWorkerRuntimes array = [
    'dotnet'
    // 'dotnet-isolated'
    'dotnet'
]
param functionOpenApiDocTitles array = [
    'In-Proc App'
    'Out-of-Proc App'
]
@allowed([
    'Device'
    'ForeignGroup'
    'Group'
    'ServicePrincipal'
    'User'
])
param deploymentScriptPrincipalType string = 'ServicePrincipal'
param deploymentScriptAzureCliVersion string = '2.33.1'

module apim './provision-apimanagement.bicep' = {
    name: 'ApiManagement_main'
    params: {
        name: name
        location: location
        apiMgmtPublisherName: apiManagementPublisherName
        apiMgmtPublisherEmail: apiManagementPublisherEmail
    }
}

module fncapps './provision-functionapp.bicep' = [for (suffix, i) in suffixes: {
    name: 'FunctionApp_main_${suffix}'
    dependsOn: [
        apim
    ]
    params: {
        name: name
        suffix: suffix
        location: location
        functionWorkerRuntime: functionWorkerRuntimes[i]
        functionOpenApiDocTitle: functionOpenApiDocTitles[i]
    }
}]

module uai './deploymentScript.bicep' = {
    name: 'UserAssignedIdentity_main'
    dependsOn: [
        apim
        fncapps
    ]
    params: {
        name: name
        location: location
        principalType: deploymentScriptPrincipalType
        azureCliVersion: deploymentScriptAzureCliVersion
    }
}
