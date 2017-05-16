
{ createNedbmgrServer } = require './server'

defaultOptions = {
  rootDir: null # null to use current working directory
  apiServer:
    port: 8501
    host: 'localhost'
    pssk: null # is an arbitary string, preshared key that the client must provide with each query. null to ignore.
  db:
    readonly: false
    allowBulkUpdates: true
    allowBulkDeletes: true
    allowNonAdminUserTo:
      useStoredFunctions: true
      addOrModifyStoredFunctions: false
    allowCustomDatabaseFilePath: true
    allowCustomDatabaseFilePathExceedingRoot: false
    predefinedDatabaseFileList: [
      {
        name: 'My Db 1'
        path: './path-to-my-db'
      }
    ]
  log:
    filePath: './nedbmgr.log'
    requests: true
    queries: true
    sessions: true
  user:
    defaultAdmin:
      name: "James Bond"
      email: "james@bond.com"
      password: "Password1"
    recoveryContact: 'help@myorg.com'
  fileServer:
    enabled: true
    customDir: null
    port: 8502
    host: 'localhost'
  https:
    apiServer:
      enabled: false
      pkey: null
      cert: null
      caBundle: null
    fileServer:
      enabled: false
      pkey: null
      cert: null
      caBundle: null
}

@createStandaloneServer = (opt, cbfn)->
  createNedbmgrServer opt, null, cbfn

@createEmbeddedServer = (opt, nedbDatabaseObject, cbfn)->
  createNedbmgrServer opt, nedbDatabaseObject, cbfn
