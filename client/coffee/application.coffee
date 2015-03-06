Editor = require './editor'
Main = require './gui/main'

Stores = require './flux/stores'
Actions = require './flux/actions'

stores =
  LayerStore: new Stores.Layers()
  QuickSelectStore: new Stores.QuickSelect()
  StateStore: new Stores.State()

flux = new Fluxxor.Flux stores, Actions
window.flux = flux

flux.on "dispatch", (type, payload) ->
  if window.debug_on
    console.log "[Dispatch]", type, payload

class Application
  init: ->
    React.render(Main(flux: flux), document.getElementById('content'))
    @editor = new Editor()

app = new Application()
app.init()
