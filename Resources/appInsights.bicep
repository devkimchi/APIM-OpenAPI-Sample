param name string
param suffix string = ''
param location string = resourceGroup().location

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

param workspaceId string

var workspace = {
    id: workspaceId
}
var appInsights = {
    name: 'appins-${name}${(suffix == '' ? '' : '-${suffix}')}'
    location: location
    appType: appInsightsType
    ingestionMode: appInsightsIngestionMode
}

resource appins 'Microsoft.Insights/components@2020-02-02' = {
    name: appInsights.name
    location: appInsights.location
    kind: 'web'
    properties: {
        Application_Type: appInsights.appType
        Flow_Type: 'Bluefield'
        IngestionMode: appInsights.ingestionMode
        Request_Source: 'rest'
        WorkspaceResourceId: workspace.id
    }
}

output id string = appins.id
output name string = appins.name
output instrumentationKey string = appins.properties.InstrumentationKey
