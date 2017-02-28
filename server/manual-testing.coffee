
{ createStandaloneServer } = require './index'

opt = {
  apiServer:
    port: 8501
    host: 'localhost'
  db:
    allowCustomDatabaseFilePath: true
    allowCustomDatabaseFilePathExceedRoot: true
}

createStandaloneServer opt, (err)=>
  if err
    throw err
