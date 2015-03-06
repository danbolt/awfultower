_c = require '../constants'

module.exports = Fluxxor.createStore
  initialize: ->
    @layers = {}
    @currentLayer = null
    @globalOpacity = true

    @bindActions(
      _c.ADD_LAYER, @addLayer
      _c.TOGGLE_LAYER_LOCKED, @toggleLayerLocked
      _c.TOGGLE_LAYER_VISIBLE, @toggleLayerVisible
      _c.CHANGE_LAYER, @changeLayer
      _c.REORDER_LAYERS, @reorderLayers
      _c.TOGGLE_GLOBAL_OPACITY, @toggleGlobalOpacity
    )

  toggleLayerLocked: (p, type) ->
    l = if p.locked? then p.locked else not @layers[p.layer].locked
    @layers[p.layer].locked = l
    @emit 'change', type, p.layer, l

  toggleLayerVisible: (p, type) ->
    v = if p.visible? then p.visible else not @layers[p.layer].visible
    @layers[p.layer].visible = v
    @emit 'change', type, p.layer, v

  changeLayer: (name, type) ->
    @currentLayer = name
    @emit 'change', type, name

  toggleGlobalOpacity: (opacity, type) ->
    o = if opacity? then opacity else not @globalOpacity
    @globalOpacity = o
    @emit 'change', type, o

  addLayer: (name, type) ->
    @layers[name] =
      name: name
      visible: true
      locked: false
      order: Object.keys(@layers).length

    @currentLayer = name

    @emit 'change', type, name

  reorderLayers: (layers, type) ->
    _.each @layers, (layer) ->
      layer.order = layers.indexOf layer.name

    @emit 'change', type, layers

  getState: ->
    layers: @layers
    currentLayer: @currentLayer
    globalOpacity: @globalOpacity
