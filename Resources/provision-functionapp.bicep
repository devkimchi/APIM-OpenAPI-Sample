param name string
param suffix string = ''
param location string = resourceGroup().location

// Storage
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

// Log Analytics Workspace
@allowed([
    'Free'
    'Standard'
    'Premium'
    'Standalone'
    'LACluster'
    'PerGB2018'
    'PerNode'
    'CapacityReservation'
])
param workspaceSku string = 'PerGB2018'

// Application Insights
@allowed([
    'web'
    'other'
])
param appInsightsType string = 'web'

@allowed([
    'ApplicationInsights'
    'ApplicationInsightsWithDiagnosticSettings'
    'LogAnalytics'
])
param appInsightsIngestionMode string = 'LogAnalytics'

// Consumption Plan
param consumptionPlanIsLinux bool = false

// Function App
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

module st './storageAccount.bicep' = {
    name: 'StorageAccount_fncapp_${suffix}'
    params: {
        name: name
        suffix: suffix
        location: location
        storageAccountSku: storageAccountSku
    }
}

module wrkspc './logAnalyticsWorkspace.bicep' = {
    name: 'LogAnalyticsWorkspace_fncapp_${suffix}'
    params: {
        name: name
        suffix: suffix
        location: location
        workspaceSku: workspaceSku
    }
}

module appins './appInsights.bicep' = {
    name: 'ApplicationInsights_fncapp_${suffix}'
    params: {
        name: name
        suffix: suffix
        location: location
        appInsightsType: appInsightsType
        appInsightsIngestionMode: appInsightsIngestionMode
        workspaceId: wrkspc.outputs.id
    }
}

module csplan './consumptionPlan.bicep' = {
    name: 'ConsumptionPlan_fncapp_${suffix}'
    params: {
        name: name
        suffix: suffix
        location: location
        consumptionPlanIsLinux: consumptionPlanIsLinux
    }
}

module fncapp './functionApp.bicep' = {
    name: 'FunctionApp_fncapp_${suffix}'
    params: {
        name: name
        suffix: suffix
        location: location
        storageAccountId: st.outputs.id
        storageAccountName: st.outputs.name
        appInsightsId: appins.outputs.id
        consumptionPlanId: csplan.outputs.id
        functionIsLinux: consumptionPlanIsLinux
        functionEnvironment: functionEnvironment
        functionExtensionVersion: functionExtensionVersion
        functionWorkerRuntime: functionWorkerRuntime
        functionWorkerVersion: functionWorkerVersion
        functionOpenApiDocTitle: functionOpenApiDocTitle
    }
}
