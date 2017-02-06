
app.behaviors.commonComputes = 

  $equals: (left, right)-> left is right

  $if: (value, thenValue, elseValue)-> if value then thenValue else elseValue

  $iff: (value)-> value

  $sum: (a,b)-> a + b

  $and: (a,b)-> a and b

  $truncate: (string, maxCount)->
    return string if string.length <= maxCount
    return (string.substr 0, (maxCount - 3)) + '...'

  $mkDate: (date)-> lib.datetime.mkDate date

