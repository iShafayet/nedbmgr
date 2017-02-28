
NedbDatastore = require('nedb')

{ parseSpecialJson } = require './fn-json'

db = null

dbFilePath = null

@useExternalDatabase = (externalNedbObject)->
  db = externalNedbObject
  dbFilePath = null

@openDatabaseFile = (filepath, cbfn)->
  db = new NedbDatastore { filename: filepath }
  db.loadDatabase (err)=>
    unless err
      dbFilePath = filepath
    return cbfn err

ensureDatabaseIsOpen = (failCbfn, successCbfn)->
  if not db
    setImmediate failCbfn, 'ERR_DB_NOT_OPENED'
  else
    setImmediate successCbfn

@getOpenedDatabaseList = getOpenedDatabaseList = ->
  if db
    return [ { name: 'Primary Database', path: dbFilePath } ]
  else
    return []

@bulkUpdate = bulkUpdate = (query, updateCommand, cbfn)->
  ensureDatabaseIsOpen cbfn, =>
    options = {
      multi: true
    }
    db.update query, updateCommand, options, (err, count)=>
      if err
        return cbfn err
      return cbfn err, count

@bulkDelete = bulkDelete = (query, cbfn)->
  ensureDatabaseIsOpen cbfn, =>
    options = {
      multi: true
    }
    db.remove query, options, (err, count)=>
      if err
        return cbfn err
      return cbfn err, count

@runQuery = runQuery = (query, skip, limit, cbfn)->
  parseSpecialJson (JSON.stringify query), (err, query)=>
    if err
      return cbfn err
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
