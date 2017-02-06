
dummyUserId = '1'
dummyEmailOrPhone = 'john@example.com'
dummyName = 'James Bond'
dummyPassword = 'Password1'
dummyApiKey = 'LB9bveGJH0rrVnmL9Bxp0MKbzu7GZz8A'

@login = (emailOrPhone, password, cbfn)->
  if emailOrPhone is dummyEmailOrPhone and password is dummyPassword
    setImmediate cbfn, null, { apiKey: dummyApiKey, name: dummyName }
  else
    setImmediate cbfn, 'ERR_INVALID_CREDENTIALS', null

@getUserIdFromApiKey = (apiKey, cbfn)->
  if apiKey is dummyApiKey
    setImmediate cbfn, null, dummyUserId
  else
    setImmediate cbfn, 'ERR_INVALID_API_KEY', null
