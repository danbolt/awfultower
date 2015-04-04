_c = require './constants'

module.exports =
  toggleErase: (erase) ->
    @dispatch _c.TOGGLE_ERASE, erase

  addLayer: (layer) ->
    @dispatch _c.ADD_LAYER, layer

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

  toggleGrid: (grid) ->
    @dispatch _c.TOGGLE_GRID, grid

  addQuickSelect: (pos, index) ->
    @dispatch _c.ADD_QUICK_SELECT,
      pos: pos
      index: index

  addToast: (type, message) ->
    @dispatch _c.ADD_TOAST,
      type: type
      message: message

  openModal: (type, props) ->
    @dispatch _c.OPEN_MODAL,
      type: type
      props: props

  closeModal: ->
    @dispatch _c.CLOSE_MODAL

  removeLayer: (layerId) ->
    @dispatch _c.REMOVE_LAYER, layerId

  renameLayer: (layerId, name) ->
    @dispatch _c.RENAME_LAYER,
      layerId: layerId
      name: name
