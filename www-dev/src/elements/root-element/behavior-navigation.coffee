

app.behaviors.local['root-element'] = {} unless app.behaviors.local['root-element']
app.behaviors.local['root-element'].navigation = [
  {

    properties:

      currentNavigationCandidate:
        type: String
        value: ''


    observers: [ 
      '_routerHrefChanged(routeData.page)'
    ]

    _routerHrefChanged: (href) ->
      # @debug '_routerHrefChanged', href
      href = '/' unless href
      wasPageFound = false
      possiblePage = null

      for page in app.pages.pageList
        if href in page.hrefList
          possiblePage = page
          wasPageFound = true
          break

      if wasPageFound
        if possiblePage.requireAuthentication
          if @isUserLoggedIn()
            @page = possiblePage
          else
            @navigateToPage '#/login'
        else
          @page = possiblePage
      else
        @page = app.pages.error404

    getPageParams: ->
      hash = window.location.hash
      hash = hash.replace '#/', ''
      partArray = hash.split '/'
      partArray.shift()
      params = {}
      for part in partArray
        if part.indexOf(':') is -1
          @showModalDialog 'Malformatted Url Given'
          break
        [ left, right ] = part.split ':'
        params[left] = right
      return params

    navigateToPage: (path)->
      window.location = path

    navigateToPreviousPage: ->
      window.history.back()

    modifyCurrentPagePath: (newPath)->
      window.history.replaceState {}, newPath, newPath

    reloadPage: ->
      window.location.reload()



  }

]