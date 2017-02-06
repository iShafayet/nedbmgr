
### =======================================
# lib.
    datetime.
      now
      format
      templates.
        date
        time
        datetime
      mkDate
      mkTime
      mkDatetime
      diff
      makeRelativeTimeString
    array.
      unique
      reverse
      minus
    util.
      Collector
      Iterator
      iterate
      Condition
      asyncIf
      delay
      Notifier
      setImmediate
      shallowCopy
      deepCopy
      shallowMerge - TODO
      callOnlyOnce - FIXME
    string.
      replaceAll
      replaceLast
    json.
      stringify
      parse
    compression.
      compress
      decompress
    security.
      hash
      encrypt
      decrypt
    localStorage.
      setItem
      getItem
      removeItem
      clear
      hasItem
    tabStorage.
      setItem
      getItem
      removeItem
      clear
      hasItem
    memStorage.
      setItem
      getItem
      removeItem
      clear
      hasItem
    database.
      DatabaseEngine
    network.
      serializeAndUrlEncode
      request
      callNedbmgrPostApi * [dependent on app.config]
      ensureBaseNetworkDelay * [dependent on app.config]
    debug

  
# 
======================================= ###

window.lib = {}

###
  @datetime
###

{ dateFormat } = window['date-format-library']

lib.datetime = {}

lib.datetime.now = -> (new Date).getTime()

lib.datetime.format = dateFormat

lib.datetime.templates = dateFormat.masks
lib.datetime.templates['date'] = 'yyyy-mm-dd'
lib.datetime.templates['time'] = 'HH:MM:ss'
lib.datetime.templates['datetime'] = 'yyyy-mm-dd HH:MM:ss'

lib.datetime.mkDate = (dateObj)-> dateFormat dateObj, lib.datetime.templates.date

lib.datetime.mkTime = (dateObj)-> dateFormat dateObj, lib.datetime.templates.time

lib.datetime.mkDatetime = (dateObj)-> dateFormat dateObj, lib.datetime.templates.datetime

lib.datetime.diff = (dateObj1, dateObj2)-> 
  time1 = if dateObj1 then dateObj1.getTime() else 0
  time2 = if dateObj2 then dateObj2.getTime() else 0
  diff = time1 - time2
  return diff

lib.datetime.makeRelativeTimeString = (diff)->
  diff = Math.round (diff / 1000)
  if diff < 60
    return "around #{diff} seconds ago"
  else if diff < 90
    return "around a minute ago"
  else
    diff = Math.round (diff / 60)
    if diff < 60
      return "around #{diff} minutes ago"
    else
      diff = Math.round (diff / 60)
      return "around #{diff} hours ago"

###
  @array
###

(->

  @unique = (array)->
    newArray = []
    for item in array
      unless item in newArray
        newArray.push item
    return newArray

  @reverse = (array)->
    newArray = (item for item in array)
    newArray.reverse()
    return newArray

  @minus = (baseArray, arrayToSubtract)->
    return (item for item in baseArray when (not (item in arrayToSubtract)))

).call (lib.array = {})


###
  @util
###

{ Collector, Iterator, iterate, Condition, asyncIf, delay, Notifier, setImmediate } = window['evolvenode-stdlib']

(->
  @Collector = Collector
  @Iterator = Iterator
  @iterate = iterate
  @Condition = Condition
  @asyncIf = asyncIf
  @delay = delay
  @Notifier = Notifier
  @setImmediate = setImmediate

  @shallowCopy = (obj)->
    return obj  if obj is null or typeof (obj) isnt "object"
    temp = new obj.constructor()
    for key of obj
      temp[key] = obj[key]
    return temp

  @deepCopy = deepCopy = (obj)->
    return obj  if obj is null or typeof (obj) isnt "object"
    temp = new obj.constructor()
    for key of obj
      temp[key] = deepCopy (obj[key])
    return temp

  _onceCalledFnList = []

  @callOnlyOnce = (fn)->
    unless fn in _onceCalledFnList
      _onceCalledFnList.push fn
      fn()

).call (lib.util = {})

###
  @string
###

(->

  @replaceAll = (str0, str1, str2, ignore)->
    ## NOTE haystack, needle, replacementNeedle
    str0.replace new RegExp(str1.replace(/([\/\,\!\\\^\$\{\}\[\]\(\)\.\*\+\?\|\<\>\-\&])/g, "\\$&"), ((if ignore then "gi" else "g"))), (if (typeof (str2) is "string") then str2.replace(/\$/g, "$$$$") else str2)

  @replaceLast = (haystack, needle, replacementNeedle)->
    pos = haystack.lastIndexOf needle
    return haystack if pos is -1
    newHaystack = (haystack.substring 0, (pos)) + replacementNeedle + (haystack.substr (pos + needle.length))

).call (lib.string = {})

###
  @json
###

(->

  ISO_8601_FULL = /^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d(\.\d+)?(([+-]\d\d:\d\d)|Z)?$/i

  @stringify = (value)-> JSON.stringify value

  @parse = (value)->
    JSON.parse value, (key, valueOfKey)->
      if typeof valueOfKey is 'string'
        # console.log valueOfKey
        if ISO_8601_FULL.test valueOfKey
          return new Date valueOfKey
      return valueOfKey

).call (lib.json = {})

###
  @compression
###

(->

  @compress = (stringValue)-> pako.deflate(stringValue, {to: 'string'})

  @decompress = (stringValue)-> pako.inflate(stringValue, { to: 'string' })

).call (lib.compression = {})

###
  @security
###

(->

  @hash = (str)-> sjcl.codec.base64.fromBits sjcl.hash.sha256.hash str

  @encrypt = (passPhrase, data)-> sjcl.encrypt passPhrase, data

  @decrypt = (passPhrase, sjclEncryptedObject)-> sjcl.decrypt passPhrase,sjclEncryptedObject

).call (lib.security = {})

###
  @localStorage
###

(->

  @setItem = (key, value)-> window.localStorage.setItem key, value

  @getItem = (key)-> window.localStorage.getItem key

  @removeItem = (key)-> window.localStorage.removeItem key

  @clear = -> window.localStorage.clear()

  @hasItem = (key)-> (window.localStorage.getItem key) isnt null

).call (lib.localStorage = {})

###
  @tabStorage
###

(->

  @setItem = (key, value)-> window.sessionStorage.setItem key, value

  @getItem = (key)-> window.sessionStorage.getItem key

  @removeItem = (key)-> window.sessionStorage.removeItem key

  @clear = -> window.sessionStorage.clear()

  @hasItem = (key)-> (window.sessionStorage.getItem key) isnt null

).call (lib.tabStorage = {})

###
  @memStorage
###

(->

  memory = {}

  @setItem = (key, value)-> 
    memory[key] = value
    return null

  @getItem = (key)-> 
    return memory[key] if key of memory
    return null

  @removeItem = (key)-> 
    delete memory[key] if key of memory
    return null

  @clear = -> 
    memory = {}
    return null

  @hasItem = (key)-> return (key of memory)

).call (lib.memStorage = {})

###
  @DatabaseEngine
###

{ DatabaseEngine } = window['database-engine']

lib.DatabaseEngine = DatabaseEngine

###
  @network
###

(->

  @serializeAndUrlEncode = serializeAndUrlEncode = (params) ->
    pairs = []
    do proc = (object=params, prefix=null) ->
      for own key, value of object
        if value instanceof Array
          for el, i in value
            proc(el, if prefix? then "#{prefix}[#{key}][]" else "#{key}[]")
        else if value instanceof Object
          if prefix?
            prefix += "[#{key}]"
          else
            prefix = key
          proc(value, prefix)
        else
          value = encodeURIComponent value
          pairs.push(if prefix? then "#{prefix}[#{key}]=#{value}" else "#{key}=#{value}")
    pairs.join('&')

  @request = request = (url, method, data, cbfn)->

    xhr = new XMLHttpRequest

    if method is 'GET'
      data = serializeAndUrlEncode data
      xhr.open method, "#{url}?#{data}", true
    else
      xhr.open method, url, true

    xhr.addEventListener 'load', (response)->
      cbfn null, response
    , false

    xhr.addEventListener 'error', (response)->
      cbfn response
    , false

    xhr.addEventListener 'abort', (response) ->
      cbfn response
    , false

    if method is 'GET'
      xhr.send()
    else
      xhr.send data

    return xhr

  @callNedbmgrPostApi = callNedbmgrPostApi = (api, data, cbfn)->
    version = app.config.masterApiVersion
    api = '/' + api if api.charAt(0) isnt '/'
    url = app.config.serverHost + '/api/' + version + api
    data = {} unless typeof data is 'object'
    data.__meta = 
      clientIdentifier: app.config.clientIdentifier
      clientVersion: app.config.clientVersion
      clientPlatform: app.config.clientPlatform
    data = lib.json.stringify data
    request url, 'POST', data, (error, response)->
      return cbfn error if error
      return cbfn null, (lib.json.parse response.target.responseText)

  @ensureBaseNetworkDelay = (fn)->
    thatTime = lib.datetime.now()
    return (args...)->
      now = lib.datetime.now()
      diff = now - thatTime
      if diff > app.options.baseNetworkDelay
        fn.apply null, args
      else
        lib.util.delay (app.options.baseNetworkDelay - diff), ->
          fn.apply null, args

).call (lib.network = {})

lib.debug = (args...)->
  console.log.apply console, args

