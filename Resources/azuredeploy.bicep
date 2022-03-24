targetScope = 'subscription'

param name string
@allowed([
    'Australia Central'
    'Australia East'
    'Australia Southeast'
    'Brazil South'
    'Canada Central'
    'Canada East'
    'Central India'
    'Central US'
    'East Asia'
    'East US'
    'East US 2'
    'France Central'
    'Germany West Central'
    'Japan East'
    'Japan West'
    'Jio India West'
    'Korea Central'
    'Korea South'
    'North Central US'
    'North Europe'
    'Norway East'
    'South Africa North'
    'South Central US'
    'South India'
    'Southeast Asia'
    'Sweden Central'
    'Switzerland North'
    'UAE North'
    'UK South'
    'UK West'
    'West Central US'
    'West Europe'
    'West India'
    'West US'
    'West US 2'
    'West US 3'
])
param location string = 'Korea Central'

param apiManagementPublisherName string
param apiManagementPublisherEmail string

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
    name: 'rg-${name}'
    location: location
}

module resources './main.bicep' = {
    name: 'Resources'
    scope: rg
    params: {
        name: name
        location: location
        apiManagementPublisherName: apiManagementPublisherName
        apiManagementPublisherEmail: apiManagementPublisherEmail
    }
}
