
{ createNedbmgrServer } = require './server'

@createStandaloneServer = (opt, cbfn)->
  createNedbmgrServer opt, null, cbfn

@createEmbeddedServer = (opt, nedbDatabaseObject, cbfn)->
  createNedbmgrServer opt, nedbDatabaseObject, cbfn
