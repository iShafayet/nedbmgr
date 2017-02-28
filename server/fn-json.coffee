
@parseSpecialJson = parseSpecialJson = (json, cbfn)->
  try
    err = undefined
    finalObject = JSON.parse json, (key, value)->
      if typeof value is 'object'
        object = value
        keys = (Object.keys object)
        if keys.length is 2 and '$exp' in keys and '$flags' in keys
          value = new RegExp object.$exp, object.$flags
        else if keys.length is 1 and '$exp' in keys
          value = new RegExp object.$exp
      return value
  catch ex
    err = ex
    finalObject = null
  return cbfn err, finalObject


  
  