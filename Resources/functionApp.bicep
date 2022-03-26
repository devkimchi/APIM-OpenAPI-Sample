param name string
param suffix string = ''
param location string = resourceGroup().location

param storageAccountId string
param storageAccountName string
param appInsightsId string
param consumptionPlanId string

param functionIsLinux bool = false

@allowed([
    'Development'
    'Staging'
    'Production'
])
param functionEnvironment string = 'Production'

@allowed([
    'v3'
    'v4'
])
param functionExtensionVersion string = 'v4'

@allowed([
    'dotnet'
    'dotnet-isolated'
    'java'
    'node'
    'python'
    'poweshell'
])
param functionWorkerRuntime string = 'dotnet'

@allowed([
    // dotnet / dotnet-isolated
    'v6.0'
    // java
    'v8'
    'v11'
    // node.js
    'v12'
    'v14'
    'v16'
    // python
    'v3.7'
    'v3.8'
    'v3.9'
    // powershell
    'v7'
])
param functionWorkerVersion string = 'v6.0'
param functionOpenApiDocTitle string = 'OpenAPI'

var storage = {
    id: storageAccountId
    name: storageAccountName
}
var consumption = {
    id: consumptionPlanId
}
var appInsights = {
    id: appInsightsId
}
var linuxFxVersionMap = {
    'dotnet': ''
    'dotnet-isolated': ''
    'java': 'Java|{0}'
    'node': 'Node|{0}'
    'python': 'Python|{0}'
    'powershell': 'PowerShell|{0}'
}
var functionApp = {
    name: 'fncapp-${name}${(suffix == '' ? '' : '-${suffix}')}'
    location: location
    kind: functionIsLinux ? 'functionapp,linux' : 'functionapp'
    linuxFxVersion: functionIsLinux ? format(linuxFxVersionMap[functionWorkerRuntime], replace(functionWorkerVersion, 'v', '')) : ''
    netFrameworkVersion: functionExtensionVersion == 'v4' ? 'v6.0' : 'v4.6'
    nodeVersion: ''
    javaVersion: !functionIsLinux && functionWorkerRuntime == 'java' ? replace(functionWorkerVersion, 'v', '') : null
    pythonVersion: ''
    powerShellVersion: !functionIsLinux && functionWorkerRuntime == 'powershell' ? replace(functionWorkerVersion, 'v', '~') : ''
    environment: functionEnvironment
    extensionVersion: replace(functionExtensionVersion, 'v', '~')
    workerRuntime: functionWorkerRuntime
    docTitle: functionOpenApiDocTitle
    hostNames: 'https://fncapp-${name}${(suffix == '' ? '' : '-${suffix}')}.azurewebsites.net/api'
}

resource fncapp 'Microsoft.Web/sites@2021-02-01' = {
    name: functionApp.name
    location: functionApp.location
    kind: functionApp.kind
    properties: {
        serverFarmId: consumption.id
        httpsOnly: true
        siteConfig: {
            linuxFxVersion: functionApp.linuxFxVersion
            netFrameworkVersion: functionApp.netFrameworkVersion
            nodeVersion: functionApp.nodeVersion
            javaVersion: functionApp.javaVersion
            pythonVersion: functionApp.pythonVersion
            powerShellVersion: functionApp.powerShellVersion
            appSettings: [
                // Common Settings
                {
                    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
                    value: '${reference(appInsights.id, '2020-02-02', 'Full').properties.InstrumentationKey}'
                }
                {
                    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
                    value: '${reference(appInsights.id, '2020-02-02', 'Full').properties.connectionString}'
                }
                {
                    name: 'AZURE_FUNCTIONS_ENVIRONMENT'
                    value: functionApp.environment
                }
                {
                    name: 'AzureWebJobsStorage'
                    value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storage.id, '2021-06-01').keys[0].value}'
                }
                {
                    name: 'FUNCTION_APP_EDIT_MODE'
                    value: 'readonly'
                }
                {
                    name: 'FUNCTIONS_EXTENSION_VERSION'
                    value: functionApp.extensionVersion
                }
                {
                    name: 'FUNCTIONS_WORKER_RUNTIME'
                    value: functionApp.workerRuntime
                }
                {
                    name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
                    value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storage.id, '2021-06-01').keys[0].value}'
                }
                {
                    name: 'WEBSITE_CONTENTSHARE'
                    value: functionApp.name
                }
                // OpenAPI
                {
                    name: 'OpenApi__DocTitle'
                    value: functionApp.docTitle
                }
                {
                    name: 'OpenApi__HostNames'
                    value: functionApp.hostNames
                }
            ]
        }
    }
}

output id string = fncapp.id
output name string = fncapp.name
