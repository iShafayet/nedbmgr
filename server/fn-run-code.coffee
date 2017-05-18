
{ 
  getRawDatabaseHandle
} = require './fn-db'

{ VM, NodeVM } = require 'vm2'

@runCode = runCode = (uid, code, cbfn)->
  getRawDatabaseHandle uid, (err, db)=>
    if err
      cbfn err
      return

    toAppend = "module.exports = (function(){\n"
    toPrepend = "\n})();"
    code = toAppend + code + toPrepend

    docList = []
    errOutput = []
    logOutput = []

    vm = new NodeVM {
      console: 'off'
      sandbox: {
        done: ->
          cbfn null, errOutput, logOutput, docList
        collect: (item)->
          if Array.isArray item
            docList = [].concat docList, item
          else
            docList.push item
        log: (args...)->
          logOutput.push { 
            dateTimeStamp: (new Date).getTime(),
            args: args
          }
        error: (args...)->
          errOutput.push { 
            dateTimeStamp: (new Date).getTime(),
            object: args[0]
            stack: (try args[0].stack catch ex then '') or ''
            message: (try args[0].message catch ex then '') or ''
          }
        query: (queryObject, localCbfn)->
          db.find queryObject, localCbfn
        update: (args...)->
          db.update.apply db, args
        insert: (args...)->
          db.insert.apply db, args
        remove: (args...)->
          db.remove.apply db, args
      }
    }
    try
      vm.run(code)
    catch ex
      cbfn ex
    
    
