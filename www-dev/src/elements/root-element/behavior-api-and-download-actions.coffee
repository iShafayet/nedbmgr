

app.behaviors.local['root-element'] = {} unless app.behaviors.local['root-element']
app.behaviors.local['root-element'].apiAndDownloadActions = [
  {

    properties:

      downloadActions:
        type: Object
        value: 
          count: 0
          seed: 0
          list: []

      apiActions:
        type: Object
        value: 
          count: 0
          seed: 0
          list: []

    notifyApiAction: (action, moreData...)->
      if action is 'start'
        @apiActions.count += 1
        @notifyPath 'apiActions.count'
        [ path ] = moreData
        obj = 
          id: @apiActions.seed++
          path: moreData[path]
          time: lib.datetime.now()
          action: 'start'
        @apiActions.list.push obj
        return obj.id
      else if action is 'done'
        @apiActions.count -= 1 unless @apiActions.count is 0
        @notifyPath 'apiActions.count'
        [ path, refId ] = moreData
        obj = 
          id: @apiActions.seed++
          path: path
          refId: refId
          action: 'done'
        @apiActions.list.push obj
        return obj.id
      else if action is 'error'
        @apiActions.count -= 1 unless @apiActions.count is 0
        @notifyPath 'apiActions.count'
        [ path, refId ] = moreData
        obj = 
          id: @apiActions.seed++
          path: path
          refId: refId
          action: 'error'
        @apiActions.list.push obj
        return obj.id

    notifyDownloadAction: (action, moreData...)->
      if action is 'start'
        @downloadActions.count += 1
        @notifyPath 'downloadActions.count'
        [ path ] = moreData
        obj = 
          id: @downloadActions.seed++
          path: moreData[path]
          time: lib.datetime.now()
          action: 'start'
        @downloadActions.list.push obj
        return obj.id
      else if action is 'done'
        @downloadActions.count -= 1 unless @downloadActions.count is 0
        @notifyPath 'downloadActions.count'
        [ path, refId ] = moreData
        obj = 
          id: @downloadActions.seed++
          path: path
          refId: refId
          action: 'done'
        @downloadActions.list.push obj
        return obj.id
      else if action is 'error'
        @downloadActions.count -= 1 unless @downloadActions.count is 0
        @notifyPath 'downloadActions.count'
        [ path, refId ] = moreData
        obj = 
          id: @downloadActions.seed++
          path: path
          refId: refId
          action: 'error'
        @downloadActions.list.push obj
        return obj.id


  }

]