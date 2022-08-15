targetScope = 'subscription'

@description('Specifies the Azure region to use.')
param location string = deployment().location

var suffix = 'logic-apps-iac-${uniqueString(subscription().id, location)}'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${suffix}'
  location: location
}

module resources 'resources.bicep' = {
  name: 'deploy-resources'
  scope: rg

  params: {
    location: location
    suffix: suffix
  }
}
