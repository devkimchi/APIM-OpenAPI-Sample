param name string
param location string = resourceGroup().location
param apis array = [
    {
        name: 'azure-ip'
        displayName: 'Azure IP'
        description: 'Azure in-proc API'
        path: 'azip'
        suffix: 'ip'
    }
    // {
    //     name: 'azure-oop'
    //     displayName: 'Azure OOP'
    //     description: 'Azure out-of-proc API'
    //     path: 'azoop'
    //     suffix: 'oop'
    // }
]

module apimapis './apiManagementApi.bicep' = [for api in apis: {
    name: 'ApiManagementApi_${api.path}'
    params: {
        name: name
        location: location
        apiMgmtApiName: api.name
        apiMgmtApiDisplayName: api.displayName
        apiMgmtApiDescription: api.description
        apiMgmtApiPath: api.path
        apiMgmtApiValue: 'https://fncapp-${name}-${api.suffix}.azurewebsites.net/api/openapi/v3.json'
    }
}]
