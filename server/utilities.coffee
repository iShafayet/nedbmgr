
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

@handleError = (err)->
  if err is 'ERR_INVALID_CREDENTIALS'
    return makeClientError err, 'Invalid credentials provided'
  else
    return makeClientError 'ERR_UNCAUGHT', err
