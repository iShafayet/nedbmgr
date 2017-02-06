
app.behaviors.utils = 

  locateParentNode: (el, nodeName)->
    while el.nodeName isnt nodeName
      el = el.parentNode
    return el

  locateRepeater: (el)->
    until el.nodeName is 'TEMPLATE'
      console.log el.nodeName
      if el.parentNode
        el = el.parentNode
      else if el.domHost
        el = el.domHost
      else
        console.log 'badluck'
        break

    return el

  # normalize event -> el = Polymer.dom(e).localTarget

