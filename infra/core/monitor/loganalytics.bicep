metadata description = 'Creates a Log Analytics workspace.'
param name string
param location string = resourceGroup().location
param tags object = {}

@description('The name of the user-assigned identity for the Log Analytics workspace')
param identityName string = ''

resource logAnalyticsIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = if (!empty(identityName)) {
  name: identityName
  location: location
  tags: tags
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}

output id string = logAnalytics.id
output name string = logAnalytics.name
output identityPrincipalId string = !empty(identityName) ? logAnalyticsIdentity.properties.principalId : ''
