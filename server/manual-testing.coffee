
{ createStandaloneServer } = require './index'

opt = {
  rootDir: null
  apiServer:
    port: 8501
    host: 'localhost'
  db:
    allowCustomDatabaseFilePath: true
    allowCustomDatabaseFilePathExceedingRoot: true
    predefinedDatabaseFileList: [
      {
        name: 'Test Database 1'
        path: './test/manual/testDatabase1.db'
      }
    ]
}

createStandaloneServer opt, (err)=>
  if err
    throw err
