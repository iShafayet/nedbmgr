

app.behaviors.local['root-element'] = {} unless app.behaviors.local['root-element']
app.behaviors.local['root-element'].commonDialogs = [
  {

    properties:


      genericModalDialogContents: 
        type: String
        value: 'Content goes here...'

      genericToastContents: 
        type: String
        value: 'Content goes here...'


    # === NOTE - Common Dialog Boxes ===

    showModalDialog: (content, doneCallback = null)->
      @genericModalDialogContents = content
      @$$('#generic-modal-dialog').toggle()
      @genericModalDialogDoneCallback = doneCallback

    genericModalDialogClosed: (e)->
      if @genericModalDialogDoneCallback
        @genericModalDialogDoneCallback()
        @genericModalDialogDoneCallback = null

    showModalPrompt: (content, doneCallback)->
      @genericModalPromptContents = content
      @$$('#generic-modal-prompt').toggle()
      @genericModalPromptDoneCallback = doneCallback

    genericModalPromptClosed: (e)->
      if e.detail.confirmed
        @genericModalPromptDoneCallback true
      else
        @genericModalPromptDoneCallback false
      @genericModalPromptDoneCallback = null

    showToast: (content)->
      @genericToastContents = content
      @$$('#toast1').open()

    genericToastTapped: (e)->
      @$$('#toast1').close()


  }

]