
dummyUserId = '1'
dummyEmailOrPhone = 'john@example.com'
dummyName = 'James Bond'
dummyPassword = 'Password1'
dummyApiKey = 'LB9bveGJH0rrVnmL9Bxp0MKbzu7GZz8A'

@userLogin = (emailOrPhone, password, cbfn)->
  if emailOrPhone is dummyEmailOrPhone and password is dummyPassword
    setImmediate cbfn, null, { apiKey: dummyApiKey, name: dummyName }
  else
    setImmediate cbfn, 'ERR_INVALID_CREDENTIALS', null

@getUserIdFromApiKey = (apiKey, cbfn)->
  if apiKey is dummyApiKey
    setImmediate cbfn, null, dummyUserId
  else
    setImmediate cbfn, 'ERR_INVALID_API_KEY', null

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