
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

@normalizeOptions = normalizeOptions = (options)->

  # default options:
  # ================

  unless apiServer of options
    options.apiServer = {}
  { apiServer } = options
  unless 'port' of apiServer
    apiServer.port = 8501
  unless 'host' of apiServer
    apiServer.host = null

  unless 'rootDir' of options
    options.rootDir = null
  unless options.rootDir
    options.rootDir = process.cwd()

  unless user of options
    options.user = {}
  { user } = options
  unless 'recoveryContact' of user
    user.recoveryContact = 'help@myorg.com'

  unless 'db' of options
    options.db = {}
  { db } = options
  unless 'readonly' of db
    db.readonly = false

  unless 'allowBulkUpdates' of db
    db.allowBulkUpdates = true
  unless 'allowBulkDeletes' of db
    db.allowBulkDeletes = true
  unless 'allowNonAdminUserTo' of db
    db.allowNonAdminUserTo = {}
  { allowNonAdminUserTo } = db
  unless 'useStoredFunctions' of allowNonAdminUserTo
    allowNonAdminUserTo.useStoredFunctions = true
  unless 'addOrModifyStoredFunctions' of allowNonAdminUserTo
    allowNonAdminUserTo.addOrModifyStoredFunctions = false
  unless 'allowCustomDatabaseFilePath' of db
    db.allowCustomDatabaseFilePath = true
  unless 'allowCustomDatabaseFilePathExceedingRoot' of db
    db.allowCustomDatabaseFilePathExceedingRoot = false
  unless 'predefinedDatabaseFileList' of db
    db.predefinedDatabaseFileList = []






  return options