_c = require './constants'

module.exports = Fluxxor.createStore
  initialize: ->
    @erase = false
    @globalOpacity = true
    @grid = true
    @layers = {}
    @currentLayer = null
    @quickSelectIndicies = (null for i in [0..9])

    @bindActions(
      _c.TOGGLE_ERASE, @toggleErase
      _c.ADD_LAYER, @addLayer
      _c.TOGGLE_LAYER_LOCKED, @toggleLayerLocked
      _c.TOGGLE_LAYER_VISIBLE, @toggleLayerVisible
      _c.CHANGE_LAYER, @changeLayer
      _c.REORDER_LAYERS, @reorderLayers
      _c.TOGGLE_GLOBAL_OPACITY, @toggleGlobalOpacity
      _c.TOGGLE_GRID, @toggleGrid
      _c.ADD_QUICK_SELECT, @addQuickSelect
    )

  addQuickSelect: ({pos, index}) ->
    return unless 0 <= pos <= 9
    @quickSelectIndicies[pos] = index
    @emit 'change'

  toggleGrid: (grid, type) ->
    g = if grid? then grid else not @grid
    @grid = g
    @emit 'change', type, g

  toggleGlobalOpacity: (opacity, type) ->
    o = if opacity? then opacity else not @globalOpacity
    @globalOpacity = o
    @emit 'change', type, o

  toggleErase: (erase, type) ->
    e = if erase? then erase else not @erase
    @erase = e
    @emit 'change', type, e

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
      layer.order = layers.indexOf(layer.name)

    @emit 'change', type, layers

  getState: ->
    erase: @erase
    globalOpacity: @globalOpacity
    layers: @layers
    grid: @grid
    currentLayer: @currentLayer
    quickSelectIndicies: @quickSelectIndicies
