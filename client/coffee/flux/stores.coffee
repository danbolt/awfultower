_c = require './constants'

module.exports = Fluxxor.createStore
  initialize: ->
    @erase = false
    @layers = {}
    @currentLayer = null

    @bindActions(
      _c.TOGGLE_ERASE, @toggleErase
      _c.ADD_LAYER, @addLayer
      _c.TOGGLE_LAYER_LOCKED, @toggleLayerLocked
      _c.TOGGLE_LAYER_VISIBLE, @toggleLayerVisible
      _c.CHANGE_LAYER, @changeLayer
      _c.REORDER_LAYERS, @reorderLayers
    )

  toggleErase: (erase) ->
    e = if erase? then erase else not @erase
    @erase = e
    @emit 'change'

  changeCurrentLayer: (layer) ->

  toggleLayerLocked: (p) ->
    l = if p.locked? then p.locked else not @layers[p.layer].locked
    @layers[p.layer].locked = l
    @emit 'change'

  toggleLayerVisible: (p) ->
    v = if p.visible? then p.visible else not @layers[p.layer].visible
    @layers[p.layer].visible = v
    @emit 'change'

  changeLayer: (name) ->
    @currentLayer = name
    @emit 'change'

  addLayer: (name) ->
    @layers[name] =
      name: name
      visible: true
      locked: false
      order: Object.keys(@layers).length

    @currentLayer = name

    @emit 'change'

  reorderLayers: (layers) ->
    _.each @layers, (layer) ->
      layer.order = layers.indexOf(layer.name)

    @emit 'change'

  getState: ->
    erase: @erase
    layers: @layers
    currentLayer: @currentLayer
