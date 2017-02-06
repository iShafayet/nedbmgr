
app.behaviors.dbUsing = 

  isUserLoggedIn: ->
    userList = app.db.find 'user'
    if userList.length is 0
      return false
    else if userList.length is 1
      return true
    else
      throw new Error 'More than one active user'

  removeAllUserInfo: ->
    app.db.remove 'user', item._id for item in app.db.find 'user'
    app.db.remove '--persistent-session', item._id for item in app.db.find '--persistent-session'
    
  removeUserUnlessSessionIsPersistent: ->
    userList = app.db.find 'user'
    persistentSessionList = app.db.find '--persistent-session'

    if userList.length is 1 and persistentSessionList.length is 1
      if persistentSessionList[0].shouldRememberUser isnt true
        item = lib.tabStorage.getItem 'is-tab-authenticated'
        if item
          if (lib.json.parse item) is false
            @removeAllUserInfo()
        else
          @removeAllUserInfo()

  loginDbAction: (user, shouldRememberUser) ->
    @removeAllUserInfo()

    app.db.insert 'user', user

    persistentSession = 
      shouldRememberUser: shouldRememberUser
    app.db.insert '--persistent-session', persistentSession

    lib.tabStorage.setItem 'is-tab-authenticated', (lib.json.stringify true)

  getCurrentUser: -> (app.db.find 'user')[0]



