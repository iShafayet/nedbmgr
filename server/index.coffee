
{ createNedbmgrServer } = require './server'

defaultOptions = {
  apiServer:
    port: 8501
    host: 'localhost'
    pssk: null # is an arbitary string, preshared key that the client must provide with each query. null to ignore.
  db:
    readonly: false
    allowBulkQueries: true
    allowNonAdminTo:
      useStoredFunctions: true
      modifyStoredFunctions: false
    allowCustomDatabaseFilePath: true
    allowCustomDatabaseFilePathExceedRoot: false
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
  defaultAdmin:
    name: "James Bond"
    email: "james@bond.com"
    password: "Password1"
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

optionsThatAreCurrentlySupported = {
  apiServer:
    port: 8501
    host: 'localhost'
}

@createStandaloneServer = (opt, cbfn)->
  createNedbmgrServer opt, null, cbfn

@createParasiteServer = (opt, nedbDatabaseObject, cbfn)->
  createNedbmgrServer opt, nedbDatabaseObject, cbfn
