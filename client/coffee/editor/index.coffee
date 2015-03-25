Minimap = require './minimap'
Stamp = require './lib/stamp'
Undo = require './undo'
Peer = require './lib/peer'
Grid = require './grid'
ServerAgent = require './server_agent'
utils = require './utils'

{tileWidth, tileHeight, sign} = utils

MAP_SIZE = {x: 100, y: 100} # TODO this needs to be configurable

module.exports = class Editor
  constructor: ->

    # Use css to size the game, hence the 100%
    @game = new Phaser.Game '100%', '100%', Phaser.AUTO, "scene",
      preload: @preload
      create: @create
      update: @update
      render: ->

    @globalOpacity = true
    @layers = {}
    @undo = new Undo @
    @bindFlux()
    @bindSocket()
    @username = null

    @peers = []

  # When a flux action is called call the appropriate method here
  bindFlux: ->
    fluxMaps =
      ADD_LAYER: @addLayer
      CHANGE_LAYER: @changeLayer
      TOGGLE_LAYER_VISIBLE: @hideLayer
      TOGGLE_LAYER_LOCKED: @lockLayer
      REORDER_LAYERS: @reorderLayers
      TOGGLE_ERASE: @toggleErase
      TOGGLE_GLOBAL_OPACITY: @changeGlobalOpacity
      TOGGLE_GRID: @toggleGrid

    for name, store of flux.stores
      store.on('change', (type, rest...) => fluxMaps[type]?(rest...))

  bindSocket: =>
    ServerAgent.bind 'add_tile', (data) =>
      @addTile data.index, data.x, data.y, @currentLayer, false, true

    ServerAgent.bind 'load_map', (data) =>
      @loadMap data

    ServerAgent.bind 'stamp_move', (data) =>
      if not @peers[data.uuid]
        @peers[data.uuid] = new Peer data.uuid, @game
      @peers[data.uuid].update data

    ServerAgent.bind 'join_room', (data) =>
      if data.users?.length
        @peers[name] = new Peer(name, @game) for name in data.users

    ServerAgent.bind 'user_joined', (data) =>
      @peers[data.uuid] = new Peer data.uuid, @game

    ServerAgent.bind 'leave_room', (data) =>
      delete @peers[data.uuid]

  preload: =>
    @game.load.spritesheet 'level', 'images/level3.png', tileWidth, tileHeight

  create: =>
    @initial_load = true
    @game.stage.backgroundColor = '#2d2d2d'
    @game.state.resize = @resize

    # Resize the world when canvas resizes
    @game.scale.scaleMode = Phaser.ScaleManager.RESIZE

    @grid = new Grid @
    Stamp.init @game
    Minimap.init @

    @game.world.add @grid.group
    @game.world.add Stamp.preview

    @map = @game.add.tilemap()
    @map.addTilesetImage 'level'
    @addLayer 'layer 1'

    @cursors = @game.input.keyboard.createCursorKeys()

    @game.input.onUp.add @mouseUp, @
    @game.input.addMoveCallback @mouseMove, @

    # Register undo and redo
    undoKey = @game.input.keyboard.addKey Phaser.Keyboard.U
    redoKey = @game.input.keyboard.addKey Phaser.Keyboard.Y
    undoKey.onDown.add ( => @undo.undo() ), @
    redoKey.onDown.add ( => @undo.redo() ), @

    @getMap()

  getMap: =>
    return unless (map = utils.getParameterByName 'map')
    ServerAgent.send 'load_map', {map: map}

  loadMap: (data) =>
    width = data.width
    height = data.height
    map = data.map

    for j in [0...height]
      for i in [0...width]
        if (tile = data['map'][(j*width) + i])? and tile isnt ''
          @addTile map[(j*width) + i], i, j, 0, false, true
        else if not @initial_load
          @addTile '-1', i, j, 0, false, true
    if @initial_load
      @initial_load = false

  # When the world resizes, this gets called
  resize: =>
    @grid.resizeGrid()
    Minimap.resizeHighlight()

  # Add a new phaser.tileMapLayer to our game
  addLayer: (name) =>

    if Object.keys(@layers).length
      # If we already have a layer, add a blank layer
      @layers[name] = @map.createBlankLayer name, MAP_SIZE.x, MAP_SIZE.y, tileWidth, tileHeight
    else
      # Create the initial layer
      @layers[name] = @map.create name, MAP_SIZE.x, MAP_SIZE.y, tileWidth, tileHeight

    @changeLayer name
    @layers[name].resizeWorld()

  lockLayer: (layer, locked) =>
    # A locked layer cannot be modified
    return unless (layer = @layers[layer])
    layer.locked = locked

  hideLayer: (layer, visible) =>
    return unless (layer = @layers[layer])
    layer.visible = visible

  # If there is global opacity, layers which are not active have opacity = 0.5
  # so you can see all the other layers. Otherwise all layers have opacity 1,
  # and are displayed based on z-index
  updateGlobalOpacity: =>
    name = @currentLayer?.name
    for n, layer of @layers
      if @globalOpacity is false
        layer.alpha = 1
      else
        layer.alpha = 1 if n is name
        layer.alpha = 0.5 if n isnt name

  changeGlobalOpacity: (opacity) =>
    @globalOpacity = opacity
    @updateGlobalOpacity()

  # Change the current layer, adjusting the opacity of the others if there is
  # global opacity
  changeLayer: (name) =>
    return if name is @currentLayer?.name
    @currentLayer = @layers[name]
    @updateGlobalOpacity()

    @orderChildren()

  # Show or hide the canvas grid
  # params:
  #   grid: boolean - visible or not visible
  toggleGrid: (grid) =>
    @grid.toggle grid

  reorderLayers: (layers) =>
    for layer in layers
      @layers[layer].bringToTop()

    @orderChildren()

  toggleErase: (erase) =>
    @erase = erase
    Stamp.setErase @erase

  # The stamp should always appear above the grid, which should always be
  # above the map. When we reorder we need to make sure this is true
  orderChildren: ->
    @game.world.bringToTop @grid.group
    @game.world.bringToTop Stamp.preview

  mouseUp: (e) =>
    # If we are band filling, fill the region
    if @bandFill
      @bandFill = false

      bounds = Stamp.bandBounds
      Stamp.endBandFill()

      w = bounds.maxX - bounds.minX
      h = bounds.maxY - bounds.minY

      # Fill the reguin that was band selected
      @fill bounds.minX, bounds.minY, w, h, @currentLayer

    # Add an undo item. Either add or remove, and pass the modified tiles
    if @modifiedTiles and Object.keys(@modifiedTiles).length
      undoAction = if @erase then '-' else '+'
      @undo.push undoAction, @modifiedTiles

    @modifiedTiles = null

  mouseMove: (e) =>
    # Get tile coords of mouse
    x = @currentLayer.getTileX @game.input.activePointer.worldX
    y = @currentLayer.getTileY @game.input.activePointer.worldY

    # What modifiers are down
    shift = @game.input.keyboard.isDown Phaser.Keyboard.SHIFT
    space = @game.input.keyboard.isDown Phaser.Keyboard.SPACEBAR
    pointer = @game.input.mousePointer.isDown

    # checks if mouse is being held
    if pointer and not @modifiedTiles
      @modifiedTiles = {}

    # We are holding space, pan the map
    if pointer and space
      # The center position of the current drag. Gets updated each time
      # the camera moves
      @mouseDrag ?= {x: x, y: y, camera: {x: @game.camera.x, y: @game.camera.y}}

      # Move the camera in the direction of dragging by tileW/H. No matter how
      # far away you are from the mouseDrag, it only goes one step
      @game.camera.x = @mouseDrag.camera.x + tileWidth * sign(x - @mouseDrag.x)
      @mouseDrag.x = x
      @mouseDrag.camera.x = @game.camera.x

      @game.camera.y = @mouseDrag.camera.y + tileHeight * sign(y - @mouseDrag.y)
      @mouseDrag.y = y
      @mouseDrag.camera.y = @game.camera.y

    # Remove the mousedrag object
    else if @mouseDrag and not (space and pointer)
      @mouseDrag = null

    # We want to start bandfilling
    else if shift and pointer and not @bandFill
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
        for i in [0..Stamp.tiles.length - 1]
          for j in [0..Stamp.tiles[i].length - 1]
            @addTile Stamp.tiles[i][j], x + i, y + j, @currentLayer

    Stamp.updateHighlight x, y

  update: =>
    # Move the camera
    if @cursors.left.isDown then @game.camera.x -= tileWidth
    if @cursors.right.isDown then @game.camera.x += tileWidth

    if @cursors.down.isDown then @game.camera.y += tileHeight
    if @cursors.up.isDown then @game.camera.y -= tileHeight

    Minimap.moveHighlight @game.camera.x / tileWidth, @game.camera.y / tileHeight

    @grid.move @game.camera.x, @game.camera.y



  # Called from minimap clicks. Move the map to an absolute position
  moveCamera: (x, y) =>
    @game.camera.x = x * MAP_SIZE.x * tileWidth - @game.width / 2
    @game.camera.y = y * MAP_SIZE.y * tileHeight - @game.height / 2

  # Fill in or remove a region
  # x and y are the min point of the region (top left)
  # w, h are the width
  # layer is the tileMapLayer
  # x, y, w, h are in tile coordinates
  fill: (x, y, w, h, layer) ->
    if @erase
      for i in [0..w]
        for j in [0..h]
          @removeTile x + i, y + j, layer
    else
      # Paint a single tile
      if Stamp.tiles[0].length is 1
        for i in [0..w]
          for j in [0..h]
            tile = Stamp.tiles[0][0]
            @addTile tile, x + i, y + j, layer

      # Repeat paint a multiselect tile
      else
        stampW = Stamp.tiles.length
        stampH = Stamp.tiles[0].length
        for i in [0..w]
          for j in [0..h]
            tile = Stamp.tiles[i % stampW][j % stampH]
            @addTile tile, x + i, y + j, @currentLayer

  # Add a tile to the map, add an undo action, basically just if this method
  # isn't being called as the result of an undo action, and add the tile to the
  # minimap
  addTile: (index, x, y, layer, addToUndo = true, fromServer = false) ->
    return if @map.getTile(x, y, layer)?.index is index
    index = parseInt index
    if addToUndo
      @modifiedTiles[x] ||= {}
      @modifiedTiles[x][y] =
        index: index
        previous: @map.getTile(x, y, layer)?.index
        layer: layer

    if not fromServer
      ServerAgent.send 'add_tile', {x: x, y: y, layer: layer.index, index: index, map_x: MAP_SIZE.x, map_y: MAP_SIZE.y}

    @map.putTile index, x, y, layer
    Minimap.addTile index, x, y

  # Remove a tile to the map, add an undo action, basically just if this method
  # isn't being called as the result of an undo action, and remove the tile
  # from the minimap
  removeTile: (x, y, layer, addToUndo = true, fromServer = false) ->
    return unless (tile = @map.getTile(x, y, layer))
    if addToUndo
      @modifiedTiles[x] ||= {}
      @modifiedTiles[x][y] =
        previous: tile.index
        layer: layer

    if not fromServer
      ServerAgent.send 'add_tile', {x: x, y: y, layer: layer.index, index: '', map_x: MAP_SIZE.x, map_y: MAP_SIZE.y}

    @map.removeTile x, y, layer
    Minimap.removeTile x, y

