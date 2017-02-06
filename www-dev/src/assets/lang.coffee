
app.lang = {}

app.lang.supportedLanguageList = [
  'en-us'
  'bn-bd'
]

app.lang.defaultLanguage = null
app.lang.defaultLanguageIndex = 0

app.lang.loadDefaultLanguage = ->
  app.lang.defaultLanguage = (lib.localStorage.getItem 'app-lang-default-language') or 'en-us'
  app.lang.defaultLanguageIndex = app.lang.supportedLanguageList.indexOf(app.lang.defaultLanguage)

app.lang.loadDefaultLanguage()

app.lang.saveDefaultLanguage = ->
  lib.localStorage.setItem 'app-lang-default-language', app.lang.defaultLanguage
  app.lang.defaultLanguageIndex = app.lang.supportedLanguageList.indexOf(app.lang.defaultLanguage)

app.lang.phrases = 
  'bn-bd':
    'new patients':'নতুন রুগী'
    'new records':'নতুন রেকর্ড'
    'view':'বিস্তারিত দেখুন'
    'total patients':'মোট রুগী'
    'total records':'মোট রেকর্ড'
    'unpaid invoices':'অপরিশোধিত ইনভয়েস'
    'days left':'দিন বাকি'
    'renew':'নবায়ন করুন'
    'purchase':'ক্রয় করুন'
    'General': 'সাধারণ'
    'Language': 'ভাষা'

app.lang.numerals = 
  'bn-bd':
    '0':'০'
    '1':'১'
    '2':'২'
    '3':'৩'
    '4':'৪'
    '5':'৫'
    '6':'৬'
    '7':'৭'
    '8':'৮'
    '9':'৯'
    '.':'.'

app.lang.translatePhrase = (phraseIdentifier, languageIdentifier)->
  if languageIdentifier of app.lang.phrases
    map = app.lang.phrases[languageIdentifier]
    return map[phraseIdentifier] if phraseIdentifier of map
  return phraseIdentifier

app.lang.translateNumeral = (numeral, languageIdentifier)->
  if languageIdentifier of app.lang.numerals
    map = app.lang.numerals[languageIdentifier]
    numeral = (''+numeral).split ''
    newNumeral = []
    for digit in numeral
      unless digit of map
        return 'TRANSLATION_FAILED FOR "' + digit + '"'
      newNumeral.push map[digit]
    return (newNumeral.join '')
  return (''+numeral)

