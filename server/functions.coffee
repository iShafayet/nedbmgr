
NedbDatastore = require('nedb')

db = null

@useExternalDatabase = (externalNedbObject)->
  db = externalNedbObject

@openDatabaseFile = (filepath, cbfn)->
  db = new NedbDatastore { filename: filepath }
  db.loadDatabase (err)=>
    return cbfn err

ensureDatabaseIsOpen = (failCbfn, successCbfn)->
  if not db
    setImmediate failCbfn, 'ERR_DB_NOT_OPENED'
  else
    setImmediate successCbfn

@runQuery = runQuery = (query, skip, limit, cbfn)->
  ensureDatabaseIsOpen cbfn, =>
    db.count query, (err, count)=>
      if err
        return cbfn err
      (((db.find query).skip skip).limit limit).exec (err, docList)=>
        return cbfn err, count, docList

@updateSingleDoc = updateSingleDoc = (doc, cbfn)->
  ensureDatabaseIsOpen cbfn, =>
    id = doc._id
    delete doc['_id']
    db.update { _id: id }, doc, (err, numAltered)=>
      if err
        return cbfn err
      doc._id = id
      cbfn err, (numAltered is 1)

@removeSingleDoc = removeSingleDoc = (id, cbfn)->
  ensureDatabaseIsOpen cbfn, =>
    db.remove { _id: id }, { multi: false }, (err, numRemoved)=>
      if err
        return cbfn err
      cbfn null, (numRemoved is 1)
