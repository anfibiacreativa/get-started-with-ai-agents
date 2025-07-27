metadata description = 'Creates a role assignment for a service principal.'

param principalId string = ''
param identityName string = ''
param location string = resourceGroup().location

@allowed([
  'Device'
  'ForeignGroup'
  'Group'
  'ServicePrincipal'
  'User'
  ''
])
param principalType string
param roleDefinitionId string

// Create managed identity if identityName is provided and principalId is not
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = if (!empty(identityName) && empty(principalId)) {
  name: identityName
  location: location
}

// Use provided principalId or get it from the created managed identity
var effectivePrincipalId = !empty(principalId) ? principalId : (!empty(identityName) ? managedIdentity.properties.principalId : '')
var principalIdForGuid = !empty(principalId) ? principalId : identityName

resource role 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, resourceGroup().id, principalIdForGuid, roleDefinitionId)
  properties: {
    principalId: effectivePrincipalId
    principalType: principalType
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
  }
  dependsOn: [
    resourceGroup() // Explicitly declare dependency on the resource group
]
}

// Output the managed identity information if created
output principalId string = effectivePrincipalId
output identityResourceId string = !empty(identityName) && empty(principalId) ? managedIdentity.id : ''
