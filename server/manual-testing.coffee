
{ createStandaloneServer } = require './index'

opt = {
  rootDir: null
  apiServer:
    port: 8501
    host: 'localhost'
  db:
    allowCustomDatabaseFilePath: true
    allowCustomDatabaseFilePathExceedingRoot: true
}

createStandaloneServer opt, (err)=>
  if err
    throw err
