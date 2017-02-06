
staticData = null

cbfnQueue = []

app.behaviors.local['root-element'] = {} unless app.behaviors.local['root-element']
app.behaviors.local['root-element'].dataLoader = [
  {

    loadStaticData: ->
      @requestForLoadingStaticData()

    getStaticData: (name, cbfn)->
      unless name of staticData
        throw new Error 'Unknown static data "' + name + '" requested'

      if staticData[name] isnt null
        lib.util.setImmediate cbfn, staticData[name]
      else
        cbfnQueue.push {
          cbfn: cbfn
          name: name
        }

    afterLoadingStaticData: (collectedData)->
      @_applyTransformations collectedData
      staticData = collectedData

      for item in cbfnQueue
        lib.util.setImmediate item.cbfn, staticData[item.name]
    
    requestForLoadingStaticData: ->

      staticDataList = [
        {
          name: 'districtList'
          url: './../static-data/district-list.json'
        }
      ]

      staticData = {}
      for item in staticDataList
        staticData[item.name] = null

      collection1 = new lib.util.Collector staticDataList.length

      it = new lib.util.Iterator staticDataList

      it.forEach (next, index, item)=>
        id = @notifyDownloadAction 'start', item.url
        successFn = lib.network.ensureBaseNetworkDelay => @notifyDownloadAction 'done', item.url, id
        lib.network.request item.url, 'GET', { fromApp: 'project-archnid' }, (errorResponse, response)=>
          if errorResponse
            alert 'xhr error'
            console.log errorResponse
            @notifyDownloadAction 'error', item.url, id
            return

          successFn()
          json = JSON.parse response.target.responseText
          collection1.collect item.name, json
        next()

      it.finally -> null

      collection1.finally (collectedData)=> 
        @afterLoadingStaticData collectedData

  }, app.behaviors.local['root-element'].dataTransformation

]