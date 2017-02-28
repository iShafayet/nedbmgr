
@makeClientError = makeClientError = (code, message)->
  {
    "statusCode": 400,
    "error": code,
    "message": message
  }

@makeStandardReply = (details)->
  {
    "statusCode": 200
    data: details
  }

knownErrorList = [
  'ERR_INVALID_CREDENTIALS'
  'ERR_DB_NOT_OPENED'
]

@handleError = (err, args...)->
  # console.log 'ERR', err

  if typeof err is 'string' and (err in knownErrorList or args.length > 0)

    if err is 'ERR_INVALID_CREDENTIALS'
      return makeClientError err, 'Invalid credentials provided. Please provide correct credentials to gain access.'

    else if err is 'ERR_DB_NOT_OPENED'
      return makeClientError err, 'Please open a database before you attempt to run any operations.'

  else if typeof err is 'object'
    message = err.message or 'No Message Provided.'
    if 'code' of err
      code = err.code
    else
      code = 'ERR_UNCAUGHT'

  else
    return makeClientError 'ERR_UNCAUGHT_NONSTANDARD_ERROR', err
