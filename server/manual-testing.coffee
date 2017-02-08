
{ createStandaloneServer } = require './index'

opt = {
  apiServer:
    port: 8501
    host: 'localhost'
}

createStandaloneServer opt, (err)=>
  if err
    throw err
