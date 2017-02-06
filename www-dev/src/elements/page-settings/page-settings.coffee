
Polymer {

  is: 'page-settings'

  behaviors: [ 
    app.behaviors.commonComputes
    app.behaviors.dbUsing
    app.behaviors.translating
    app.behaviors.pageLike
  ]

  properties:
    settings:
      type: Object
      notify: true
    languageSelectedIndex: 
      type: Number
      value: app.lang.defaultLanguageIndex
      notify: true
      observer: 'languageSelectedIndexChanged'

  languageSelectedIndexChanged: ->
    value = @supportedLanguageList[@languageSelectedIndex]
    @setActiveLanguage value

  _saveSettings: ->
    app.db.upsert 'settings', @settings, ({serial})-> serial is 'only'

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  saveButtonPressed: (e)->
    @_saveSettings()
    @domHost.showToast 'Settings Saved!'

  _makeSettings: ->
    settings = 
      serial: 'only'
      isSyncEnabled: false
      monetaryUnit: 'BDT'

  navigatedIn: ->
    list = app.db.find 'settings', ({serial})-> serial is 'only'
    if list.length is 0
      @settings = @_makeSettings()
    else
      @settings = list[0]


}
