@description('The suffix to use in resource naming.')
param suffix string
param location string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: substring('stor${replace(suffix, '-', '')}', 0, 24)
  location: location

  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource tableStorageService 'Microsoft.Storage/storageAccounts/tableServices@2021-09-01' = {
  name: 'default'
  parent: storageAccount
}

resource storageTable 'Microsoft.Storage/storageAccounts/tableServices/tables@2021-09-01' = {
  name: 'logicAppCalls'
  parent: tableStorageService
}

resource tableStorageConnection 'Microsoft.Web/connections@2018-07-01-preview' = {
  name: 'tableStorage'
  location: location

  properties: {
    parameterValueSet: {
      name: 'managedIdentityAuth'
      values: {}
    }
    api: {
      id: '${subscription().id}/providers/Microsoft.Web/locations/${location}/managedApis/azuretables'
    }
  }
}

var connectionApiName = tableStorageConnection.properties.api.name
resource logicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: 'ala-${suffix}'
  location: location

  identity: {
    type: 'SystemAssigned'
  }

  properties: {
    definition: loadJsonContent('../logic_apps/insertIntoTableStorage.json')
    parameters: {
      '$connections': {
        value: {
          '${connectionApiName}': {
            connectionId: tableStorageConnection.id
            connectionName: connectionApiName
            id: '${subscription().id}/providers/Microsoft.Web/locations/${location}/managedApis/${connectionApiName}'
            connectionProperties: {
              authentication: {
                type: 'ManagedServiceIdentity'
              }
            }
          }
        }
      }
      storageAccountName: {
        value: storageAccount.name
      }
    }
  }
}

var roleDefinitionId = '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3' // Storage Table Data Contributor
resource logicAppTableStorageRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(logicApp.id, roleDefinitionId)
  scope: storageAccount

  properties: {
    principalId: logicApp.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalType: 'ServicePrincipal'
  }
}
