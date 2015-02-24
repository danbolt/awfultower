Minimap = require './minimap'
Stamp = require './lib/stamp'
Undo = require './undo'

_c = require '../flux/constants'

{tileWidth, tileHeight} = require './utils'

MAP_SIZE = {x: 100, y: 100}

module.exports = class Editor
  constructor: ->

    fluxMaps =
      ADD_LAYER: @addLayer
      CHANGE_LAYER: @changeLayer
      TOGGLE_LAYER_VISIBLE: @hideLayer
      TOGGLE_LAYER_LOCKED: @lockLayer
      REORDER_LAYERS: @reorderLayers
      TOGGLE_ERASE: @toggleErase

    @game = new Phaser.Game 800, 800, Phaser.AUTO, "scene",
      preload: @preload
      create: @create
      update: @update
      render: @render

    @layers = {}
    @undo = new Undo @

    flux.store("Store").on 'change', (type, rest...) =>
      fluxMaps[type]?(rest...)

  preload: =>
    @game.load.spritesheet('level', 'images/level3.png', tileWidth, tileHeight)

  create: =>

    @game.stage.backgroundColor = '#2d2d2d'

    @cursors = @game.input.keyboard.createCursorKeys()

    @map = @game.add.tilemap()
    @map.addTilesetImage('level')

    @addLayer("layer 1")

    @game.input.onUp.add @mouseUp, @
    @game.input.addMoveCallback @mouseMove, @

    undoKey = @game.input.keyboard.addKey(Phaser.Keyboard.U)
    redoKey = @game.input.keyboard.addKey(Phaser.Keyboard.R)
    undoKey.onDown.add (=> @undo.undo()), @
    redoKey.onDown.add (=> @undo.redo()), @

    Stamp.init @game
    Minimap.init @

  addLayer: (name) =>
    if Object.keys(@layers).length
      @layers[name] = @map.createBlankLayer name, MAP_SIZE.x, MAP_SIZE.y, tileWidth, tileHeight
    else
      @layers[name] = @map.create name, MAP_SIZE.x, MAP_SIZE.y, tileWidth, tileHeight
    @layers[name].resizeWorld()
    @layers[name].visible = true
    @layers[name].locked = false
    @changeLayer name

  lockLayer: (layer, locked) =>
    return unless (layer = @layers[layer])
    layer.locked = locked

  hideLayer: (layer, visible) =>
    return unless (layer = @layers[layer])
    layer.visible = visible

  changeLayer: (name) =>
    return if name is @currentLayer?.name
    @currentLayer = @layers[name]
    for n, layer of @layers
      layer.alpha = 1 if n is name
      layer.alpha = 0.5 if n isnt name

  reorderLayers: (layers) =>
    for layer in layers
      @layers[layer].bringToTop()

  toggleErase: (erase) =>
    @erase = erase
    Stamp.setErase @erase

  mouseUp: (e) =>
    if @bandFill
      @bandFill = false

      bounds = Stamp.bandBounds
      Stamp.endBandFill()

      w = bounds.maxX - bounds.minX
      h = bounds.maxY - bounds.minY

      @fill bounds.minX, bounds.minY, w, h, @currentLayer

    undoAction = if @erase then '-' else '+'

    if @modifiedTiles and Object.keys(@modifiedTiles).length
      @undo.push undoAction, @modifiedTiles

    @modifiedTiles = null

  mouseMove: =>
    x = @currentLayer.getTileX(@game.input.activePointer.worldX)
    y = @currentLayer.getTileY(@game.input.activePointer.worldY)

    shift = @game.input.keyboard.isDown(Phaser.Keyboard.SHIFT)
    pointer = @game.input.mousePointer.isDown

    # checks if mouse is being held
    if pointer and not @modifiedTiles
      @modifiedTiles = {}
    if shift and pointer and not @bandFill
      Stamp.beginBandFill x, y
      @bandFill = true
    else if not shift and @bandFill
      @bandFill = false
      Stamp.endBandFill()
    else if pointer and not @currentLayer.locked and not @bandFill
      if @erase
        @removeTile x, y, @currentLayer
      else
        for i in [0..Stamp.tiles.length-1]
          for j in [0..Stamp.tiles[i].length-1]
            @addTile Stamp.tiles[i][j], x + i, y + j, @currentLayer

    Stamp.updateHighlight x, y

  update: =>
    if @cursors.left.isDown then @game.camera.x -= tileWidth / 2
    if @cursors.right.isDown then @game.camera.x += tileWidth / 2

    if @cursors.down.isDown then @game.camera.y += tileHeight / 2
    if @cursors.up.isDown then @game.camera.y -= tileHeight / 2

    Minimap.moveHighlight @game.camera.x / tileWidth, @game.camera.y / tileHeight

  moveCamera: (x, y) =>
    @game.camera.x = x * MAP_SIZE.x * tileWidth - 400
    @game.camera.y = y * MAP_SIZE.y * tileHeight - 400

  render: ->

  fill: (x, y, w, h, layer) ->
    if @erase
      for i in [0..w-1]
        for j in [0..h-1]
          @removeTile x+i, y+j, layer
    else
      if Stamp.tiles[0].length is 1
        for i in [0..w-1]
          for j in [0..h-1]
            @addTile Stamp.tiles[0][0], x+i, y+j, layer
      else
        stampW = Stamp.tiles.length
        stampH = Stamp.tiles[0].length
        for i in [0..w-1]
          for j in [0..h-1]
            @addTile Stamp.tiles[i%stampW][j%stampH], x + i, y + j, @currentLayer

  addTile: (index, x, y, layer, addToUndo = true) =>
    return if @map.getTile(x, y, layer)?.index is index
    if addToUndo
      @modifiedTiles[x] ||= {}
      @modifiedTiles[x][y] =
        index: index
        previous: @map.getTile(x, y, layer)?.index
        layer: layer

    @map.putTile index, x, y, layer
    Minimap.addTile index, x, y

  removeTile: (x, y, layer, addToUndo = true) =>
    return unless (tile = @map.getTile(x, y, layer))
    if addToUndo
      @modifiedTiles[x] ||= {}
      @modifiedTiles[x][y] =
        previous: tile.index
        layer: layer

    @map.removeTile x, y, layer
    Minimap.removeTile x, y



