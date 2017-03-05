
NedbDatastore = require('nedb')

QUERY_STORE_FILEPATH = './query-store.db'

db = null

ensureDatabaseIsOpen = (failCbfn, successCbfn)->
  if not db
    setImmediate failCbfn, 'ERR_QUERY_STORE_DB_NOT_OPENED'
  else
    setImmediate successCbfn

@initiateQueryStore = (cbfn)->
  db = new NedbDatastore { filename: QUERY_STORE_FILEPATH }
  db.loadDatabase (err)=>
    return cbfn err

@fetchStoredQueryList  = (cbfn)->
  skip = 0
  limit = 9999
  query = {
    collection: 'stored-query'
  }
  ensureDatabaseIsOpen cbfn, =>
    (((db.find query).skip skip).limit limit).exec (err, docList)=>
      return cbfn err, docList

@saveQueryInQueryStore = (detailedQueryObject, cbfn)->
  ensureDatabaseIsOpen cbfn, =>
    { idOnServer, type, body, nameAndTagString } = detailedQueryObject
    if idOnServer
      doc = {
        $set: {
          type
          body
          nameAndTagString
        }
      }
      db.update { _id: idOnServer }, doc, { multi: false }, (err, numUpdated)=>
        return cbfn err, doc
    else
      doc = {
        type
        body
        nameAndTagString
        collection: 'stored-query'
      }
      db.insert doc, (err, newDoc)=>
        return cbfn err, newDoc

@deleteQueryFromQueryStore = (id, cbfn)->
  ensureDatabaseIsOpen cbfn, =>
    db.remove { _id: id }, { multi: false }, (err, numRemoved)=>
      if err
        return cbfn err
      cbfn null, (numRemoved is 1)
