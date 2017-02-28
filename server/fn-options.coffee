
@normalizeOptions = normalizeOptions = (options)->

  # default options:
  # ================
  # apiServer:
  #   port: 8501
  #   host: 'localhost'
  # db:
  #   allowCustomDatabaseFilePath: true
  #   allowCustomDatabaseFilePathExceedRoot: true

  unless apiServer of options
    options.apiServer = {}
  { apiServer } = options
  unless 'port' of apiServer
    apiServer.port = 8501
  unless 'host' of apiServer
    apiServer.host = null

  unless db of options
    options.db = {}
  { db } = options
  unless 'allowCustomDatabaseFilePath' of db
    db.allowCustomDatabaseFilePath = true
  unless 'allowCustomDatabaseFilePathExceedRoot' of db
    db.allowCustomDatabaseFilePathExceedRoot = true

  return options