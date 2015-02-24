Minimap = require './minimap'
Stamp = require './lib/stamp'
Undo = require './undo'

_c = require '../flux/constants'

{tileWidth, tileHeight} = require './utils'

MAP_SIZE = {x: 100, y: 100}

module.exports = class Editor
  constructor: ->

    # When a flux action is called call the appropriate method here
    fluxMaps =
      ADD_LAYER: @addLayer
      CHANGE_LAYER: @changeLayer
      TOGGLE_LAYER_VISIBLE: @hideLayer
      TOGGLE_LAYER_LOCKED: @lockLayer
      REORDER_LAYERS: @reorderLayers
      TOGGLE_ERASE: @toggleErase

    flux.store("Store").on 'change', (type, rest...) =>
      fluxMaps[type]?(rest...)

    @game = new Phaser.Game 800, 800, Phaser.AUTO, "scene",
      preload: @preload
      create: @create
      update: @update
      render: ->

    @layers = {}
    @undo = new Undo @

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

    # Register undo and redo
    undoKey = @game.input.keyboard.addKey(Phaser.Keyboard.U)
    redoKey = @game.input.keyboard.addKey(Phaser.Keyboard.R)
    undoKey.onDown.add (=> @undo.undo()), @
    redoKey.onDown.add (=> @undo.redo()), @

    Stamp.init @game
    Minimap.init @

  # Add a new phaser.tileMapLayer to our game
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
    # If we are band filling, fill the region
    if @bandFill
      @bandFill = false

      bounds = Stamp.bandBounds
      Stamp.endBandFill()

      w = bounds.maxX - bounds.minX
      h = bounds.maxY - bounds.minY

      @fill bounds.minX, bounds.minY, w, h, @currentLayer

    # Add an undo item. Either add or remove, and pass the modified tiles
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
    # We want to start bandfilling
    if shift and pointer and not @bandFill
      Stamp.beginBandFill x, y
      @bandFill = true
    # We want to cancel bandfilling, but not actually fill
    else if not shift and @bandFill
      @bandFill = false
      Stamp.endBandFill()
    # Otherwise just paint, picasso!
    else if pointer and not @currentLayer.locked and not @bandFill
      # ...Or erase
      if @erase
        @removeTile x, y, @currentLayer
      else
        # Add all tiles in a multi tile select
        for i in [0..Stamp.tiles.length-1]
          for j in [0..Stamp.tiles[i].length-1]
            @addTile Stamp.tiles[i][j], x + i, y + j, @currentLayer

    Stamp.updateHighlight x, y

  update: =>
    # Move the camera
    if @cursors.left.isDown then @game.camera.x -= tileWidth / 2
    if @cursors.right.isDown then @game.camera.x += tileWidth / 2

    if @cursors.down.isDown then @game.camera.y += tileHeight / 2
    if @cursors.up.isDown then @game.camera.y -= tileHeight / 2

    Minimap.moveHighlight @game.camera.x / tileWidth, @game.camera.y / tileHeight

  # Called from minimap clicks. Move the map to an absolute position
  moveCamera: (x, y) =>
    @game.camera.x = x * MAP_SIZE.x * tileWidth - 400
    @game.camera.y = y * MAP_SIZE.y * tileHeight - 400

  # Fill in or remove a region
  # x and y are the min point of the region (top left)
  # w, h are the width
  # layer is the tileMapLayer
  # x, y, w, h are in tile coordinates
  fill: (x, y, w, h, layer) ->
    if @erase
      for i in [0..w-1]
        for j in [0..h-1]
          @removeTile x+i, y+j, layer
    else
      # Paint a single tile
      if Stamp.tiles[0].length is 1
        for i in [0..w-1]
          for j in [0..h-1]
            @addTile Stamp.tiles[0][0], x+i, y+j, layer

      # Repeat paint a multiselect tile
      else
        stampW = Stamp.tiles.length
        stampH = Stamp.tiles[0].length
        for i in [0..w-1]
          for j in [0..h-1]
            @addTile Stamp.tiles[i%stampW][j%stampH], x + i, y + j, @currentLayer

  # Add a tile to the map, add an undo action, basically just if this method
  # isn't being called as the result of an undo action, and add the tile to the
  # minimap
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

  # Remove a tile to the map, add an undo action, basically just if this method
  # isn't being called as the result of an undo action, and remove the tile
  # from the minimap
  removeTile: (x, y, layer, addToUndo = true) =>
    return unless (tile = @map.getTile(x, y, layer))
    if addToUndo
      @modifiedTiles[x] ||= {}
      @modifiedTiles[x][y] =
        previous: tile.index
        layer: layer

    @map.removeTile x, y, layer
    Minimap.removeTile x, y



