

app.behaviors.local['root-element'] = {} unless app.behaviors.local['root-element']
app.behaviors.local['root-element'].pageReadyMechanism = [
  {

    properties:
      readyPageNodeNameList:
        type: Array
        value: []


    # === NOTE - The code below generates the pseudo-lifetime-callback 'navigatedIn' ===

    ironPagesSelectedEvent: (e)->
      return unless Polymer.dom(e).rootTarget.nodeName is 'IRON-PAGES'
      nodeName = e.detail.item.nodeName
      for readyPageNodeName in @readyPageNodeNameList
        if readyPageNodeName is nodeName
          e.detail.item.navigatedIn() if e.detail.item.navigatedIn
          return
      @currentNavigationCandidate = nodeName

    pageReady: (pageElement)->
      @readyPageNodeNameList.push pageElement.nodeName
      if @currentNavigationCandidate is pageElement.nodeName
        @currentNavigationCandidate = ''
        pageElement.navigatedIn() if pageElement.navigatedIn

    ironPagesDeselectedEvent: (e)->
      return unless Polymer.dom(e).rootTarget.nodeName is 'IRON-PAGES'
      nodeName = e.detail.item.nodeName
      for readyPageNodeName in @readyPageNodeNameList
        if readyPageNodeName is nodeName
          e.detail.item.navigatedOut() if e.detail.item.navigatedOut
          return

  }

]