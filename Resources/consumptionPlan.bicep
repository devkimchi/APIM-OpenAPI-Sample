param name string
param suffix string = ''
param location string = resourceGroup().location

param consumptionPlanIsLinux bool = false

var consumption = {
    name: 'csplan-${name}${(suffix == '' ? '' : '-${suffix}')}'
    location: location
    isLinux: consumptionPlanIsLinux
}

resource csplan 'Microsoft.Web/serverfarms@2021-02-01' = {
    name: consumption.name
    location: consumption.location
    kind: 'functionApp'
    sku: {
        name: 'Y1'
        tier: 'Dynamic'
    }
    properties: {
        reserved: consumption.isLinux
    }
}

output id string = csplan.id
output name string = csplan.name
