Editor = require './editor'
Main = require './gui/main'

Stores = require './flux/stores'
Actions = require './flux/actions'

ServerAgent = require './editor/server_agent'

stores =
  LayerStore: new Stores.Layers()
  QuickSelectStore: new Stores.QuickSelect()
  StateStore: new Stores.State()
  ToastStore: new Stores.Toast()
  ModalStore: new Stores.Modal()

flux = new Fluxxor.Flux stores, Actions
window.flux = flux

flux.on "dispatch", (type, payload) ->
  if window.debug_on
    console.log "[Dispatch]", type, payload

class Application
  init: ->
    React.render(Main(flux: flux), document.getElementById('content'))
    @editor = new Editor()

    ServerAgent.bind 'toast', (data) ->
      flux.actions.addToast data.type, data.message

app = new Application()
app.init()
