

app.behaviors.local['root-element'] = {} unless app.behaviors.local['root-element']
app.behaviors.local['root-element'].navigation = [
  {

    properties:

      currentNavigationCandidate:
        type: String
        value: ''

    _preloadOtherPages: ->
      # @debug '_preloadOtherPages'
      fullPageList = [].concat app.pages.pageList, [ app.pages.error404 ]

      for page in fullPageList
        do (page)=>
          unless page.name is @page.name
            pagePath = @resolveUrl ('../' + page.element + '/' + page.element + '.html')
            id = @notifyDownloadAction 'start', pagePath
            successCbfn = lib.network.ensureBaseNetworkDelay => @notifyDownloadAction 'done', pagePath, id
            failureCbfn = lib.network.ensureBaseNetworkDelay => @notifyDownloadAction 'error', pagePath, id
            @importHref pagePath, successCbfn, failureCbfn, true


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

      if @isUserLoggedIn()
        @user = @getCurrentUser()
      else
        @user = null
      
      @openedDatabaseFn = =>
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

      if @user and @user.apiKey
        @_callOpenedDatabaseFn()
      else
        @openedDatabaseFn()

    _fillIronPagesFromPageList: ->
      ironPages = Polymer.dom(@root).querySelector 'iron-pages'

      fullPageList = [].concat app.pages.pageList, app.pages.error404

      for page in fullPageList
        pageElement = document.createElement page.element
        pageElement.setAttribute 'name', page.name

        Polymer.dom(ironPages).appendChild pageElement



    # === NOTE - navigation code ===

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