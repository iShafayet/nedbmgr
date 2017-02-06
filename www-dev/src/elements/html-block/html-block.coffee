
Polymer {

  is: 'html-block'

  properties:
    html:
      type: String
      notify: true
      value: 'none'
      observer: 'htmlChanged'

  htmlChanged: ->
    Polymer.dom(@root).querySelector('.content-wrapper').innerHTML = @html

}
