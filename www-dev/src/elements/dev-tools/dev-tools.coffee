




Polymer {
  is: 'dev-tools'

  detached: ->

    console.log 'detached'

  attached: ->

    console.log 'attached'

  created: ->

    console.log 'created'

    # @domHost.$$('iron-pages').addEventListener 'iron-select', (e)->
    #   console.log 'sel'
    # , false

  navigatedIn: ->

    console.trace 'navigatedIn'

  navigatedOut: ->
    console.trace 'navigatedOut'

  ready: ->

    @domHost.pageReady @

    console.log 'ready'

    master = {}

    for collectionName in app.db.getCollectionNameList()

      master[collectionName] = app.db.find collectionName

    @dbDump = JSON.stringify master, null, 2

  cleanseClicked: ->

    window.localStorage.clear()
    window.sessionStorage.clear()
    window.location = '#/'
    window.location.reload()

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

}




