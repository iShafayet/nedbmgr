
app.behaviors.translating = 

  properties:
    LANG: 
      type: String
      notify: true
      value: app.lang.defaultLanguage
    supportedLanguageList:
      type: Array
      value: []

  created: ->
    @supportedLanguageList = app.lang.supportedLanguageList

  setActiveLanguage: (languageIdentifier)->
    return unless languageIdentifier in @supportedLanguageList
    unless @LANG is languageIdentifier
      @set 'LANG', languageIdentifier
      app.lang.defaultLanguage = languageIdentifier
      app.lang.saveDefaultLanguage()

  $TRANSLATE_NUMBER: (number, languageIdentifier)->
    app.lang.translateNumeral number, languageIdentifier

  $TRANSLATE: (phraseIndentifier, languageIdentifier)->
    app.lang.translatePhrase phraseIndentifier, languageIdentifier

