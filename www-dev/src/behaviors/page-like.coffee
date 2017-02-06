
app.behaviors.pageLike = [
  {
    ready: ->
      # @debugInfo 'ready'
      @domHost.pageReady @

    # navigatedIn: ->
    #   @debugInfo 'navigatedIn'

    # navigatedOut: ->
    #   @debugInfo 'navigatedOut'

    $ofHost: (path)->
      @domHost.get path
  }
  , app.behaviors.debug
]