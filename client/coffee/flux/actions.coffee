_c = require './constants'

module.exports =
  toggleErase: (erase) ->
    @dispatch _c.TOGGLE_ERASE, erase

  addLayer: (name) ->
    @dispatch _c.ADD_LAYER, name

  toggleLayerLocked: (layer, locked) ->
    @dispatch _c.TOGGLE_LAYER_LOCKED,
      layer: layer
      locked: locked

  toggleLayerVisible: (layer, visible) ->
    @dispatch _c.TOGGLE_LAYER_VISIBLE,
      layer: layer
      visible: visible

  changeLayer: (layer) ->
    @dispatch _c.CHANGE_LAYER, layer

  reorderLayers: (layers) ->
    @dispatch _c.REORDER_LAYERS, layers

  toggleGlobalOpacity: (opacity) ->
    @dispatch _c.TOGGLE_GLOBAL_OPACITY, opacity
