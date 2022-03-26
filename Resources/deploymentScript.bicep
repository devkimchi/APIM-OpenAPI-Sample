param name string
param location string = resourceGroup().location

@allowed([
    'Device'
    'ForeignGroup'
    'Group'
    'ServicePrincipal'
    'User'
])
param principalType string = 'ServicePrincipal'
param azureCliVersion string = '2.33.1'

var userAssignedIdentity = {
    name: 'spn-${name}-deployer'
    location: location
}

resource uai 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
    name: userAssignedIdentity.name
    location: userAssignedIdentity.location
}

var roleAssignment = {
    name: guid(resourceGroup().id, 'owner')
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
    principalType: principalType
}

resource role 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
    name: roleAssignment.name
    scope: resourceGroup()
    properties: {
        roleDefinitionId: roleAssignment.roleDefinitionId
        principalId: uai.properties.principalId
        principalType: roleAssignment.principalType
    }
}

var deploymentScript = {
    name: 'depscrpt-${name}'
    containerGroupName: 'contgrp-${name}'
    location: location
    azureCliVersion: azureCliVersion
    scriptUri: 'https://raw.githubusercontent.com/devkimchi/APIM-OpenAPI-Sample/main/Resources/setup-apim.sh'
}

resource ds 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: deploymentScript.name
  location: deploymentScript.location
  dependsOn: [
      role
  ]
  kind: 'AzureCLI'
  identity: {
      type: 'UserAssigned'
      userAssignedIdentities: {
          '${uai.id}': {}
      }
  }
  properties: {
      azCliVersion: deploymentScript.azureCliVersion
      containerSettings: {
        containerGroupName: deploymentScript.containerGroupName
      }
      environmentVariables: [
          {
              name: 'RESOURCE_NAME'
              value: deploymentScript.name
          }
      ]
      primaryScriptUri: deploymentScript.scriptUri
      retentionInterval: 'P1D'
  }
}
