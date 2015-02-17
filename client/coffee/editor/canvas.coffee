Preload = require '../preload/load'
Tile = require './lib/tile'
Layer = require './lib/layer'
Minimap = require './minimap'

em = require '../event_manager'

{tileWidth, tileHeight} = require './utils'

MOVE_DISTANCE =  tileWidth
GRID_COLOR = "#e5e5e5"

class Canvas extends createjs.Container
  constructor: ->
    super

  init: ->
    @tile = 0

    @brushSize = 1

    @newTiles = []

    @gridOn = true
    Minimap.canvas = @

    em.register 'keydown', @keydown
    em.register 'keyup', @keyup
    em.register 'toggle-grid', @toggleGrid
    em.register 'toggle-erase', @toggleErase
    em.register 'add-layer', @addLayer
    em.register 'change-layer', @changeLayer
    em.register 'hide-layer', @hideLayer
    em.register 'lock-layer', @lockLayer
    em.register 'reorder-layers', @reorderLayers

    # Tile map!
    data =
      images: [Preload.loader.getResult('level')]
      frames:
        width: tileWidth
        height: tileHeight

    @tilesheet = new createjs.SpriteSheet data

    @on 'added', ->
      @width = @stage.canvas.width
      @addHighlight()
      @addGrid()

    @layers = {}

  lockLayer: (name) =>
    return unless (layer = @layers[name])
    layer.locked = not layer.locked

  hideLayer: (name) =>
    return unless (layer = @layers[name])
    layer.visible = not layer.visible

  changeLayer: (name) =>
    @currentLayer = @layers[name] if @layers[name]

  reorderLayers: (layers) =>
    for layer, i in layers
      @setChildIndex @layers[layer], i

  addLayer: (name) =>
    @currentLayer = new Layer(@, name)
    @layers[name] = @currentLayer
    @addChild(@currentLayer)

  keydown: (e) =>
    switch e.keyCode
      when 85 # u
        @currentLayer.undo()
        Minimap.recalculate()
      when 82 # r
        @currentLayer.redo()
        Minimap.recalculate()
      when 16 # shift
        @_SHIFT_DOWN = true
      when 72,74,75,76 # hjkl
        @panKeyChanged(true, e)

  keyup: (e) =>
    switch e.keyCode
      when 16
        @_SHIFT_DOWN = false
      when 72,74,75,76
        @panKeyChanged(false, e)

  panKeyChanged: (down, e) =>
    if e.keyCode is 72
      @left = down
    else if e.keyCode is 76
      @right = down
    else if e.keyCode is 74
      @up = down
    else if e.keyCode is 75
      @down = down

    if not down and e.keyCode in [72, 74, 75, 76]
      Minimap.drawViewport()

  toggleGrid: (gridOn) =>
    @gridOn = gridOn
    @toggleGrid = true

  toggleErase: (eraseOn) =>
    @erase = eraseOn

  changeBrushSize: (size) ->
    @brushSize = size
    @addHighlight()

  moveHighlight: ->
    {x,y} = @gridCoords(@stage.mouseX, @stage.mouseY)
    x *= tileWidth
    y *= tileHeight

    @selection.x = x - (tileWidth * (@brushSize-1))
    @selection.y = y - (tileHeight * (@brushSize-1))

  # This is the square that highlights which cell you are on
  addHighlight: =>

    @removeChild(@selection) if @selection

    x = Math.floor(@stage.mouseX / tileWidth) * tileWidth
    y = Math.floor(@stage.mouseY / tileHeight) * tileHeight

    index = @tile

    @selection = new createjs.Container()

    for i in [0..(@brushSize - 1)*2]
      for j in [0..(@brushSize - 1)*2]
        tile = new Tile(i, j, index, @tilesheet)
        tile.alpha = 0.3
        @selection.addChild tile

    @selection.x = x - (tileWidth * ( @brushSize - 1) )
    @selection.y = y - (tileHeight * ( @brushSize - 1) )

    g = new createjs.Graphics()
    g.beginStroke("black")
    g.setStrokeStyle(2)
    g.drawRect(0, 0, (tileWidth * ((@brushSize - 1)*2 + 1)), (tileHeight * ((@brushSize - 1)*2 + 1)))
    border = new createjs.Shape(g)

    @selection.addChild border

    @addChild(@selection)

  changeTile: (index) ->
    @tile = index
    @addHighlight()


  bounds: =>
    maxX = maxY = 0
    minX = minY = 9999
    for name, layer of @layers
      minX = layer.bounds.x.min if layer.bounds.x.min < minX
      minY = layer.bounds.y.min if layer.bounds.y.min < minY

      maxX = layer.bounds.x.max if layer.bounds.x.max > maxX
      maxY = layer.bounds.y.max if layer.bounds.x.max > maxY

    {maxX: maxX, maxY: maxY, minX: minX, minY: minY}

  mapWidth: =>
    width = @stage.canvas.width / tileWidth
    bounds = @bounds()
    regX = @regX / tileWidth

    for name, layer of @layers
      width = layer.width() if layer.width() > width

    width = Math.max(
      width
      Math.max(
        Math.abs(bounds.maxX - regX)
        Math.abs(bounds.minX - (regX + @stage.canvas.width / tileWidth))
      )
    )

  mapHeight: =>
    height = @stage.canvas.height / tileHeight
    bounds = @bounds()
    regY = @regY / tileHeight

    for name, layer of @layers
      height = layer.height() if layer.height() > height

    height = Math.max(
      height
      Math.max(
        Math.abs(bounds.maxY - regY)
        Math.abs(bounds.minY - (regY + @stage.canvas.height / tileHeight))
      )
    )

  hideViewportTiles: ->
    x = Math.floor(@regX / tileWidth)
    y = Math.floor(@regY / tileHeight)

    width = Math.floor(@stage.canvas.width / tileWidth)
    height = Math.floor(@stage.canvas.height / tileHeight)


    for name, layer of @layers
      for i in [x..x + width]
        for j in [y..y + height]
          layer.tiles[i]?[j]?.visible = false

  showViewportTiles: ->
    x = Math.floor(@regX / tileWidth)
    y = Math.floor(@regY / tileHeight)

    width = Math.floor(@stage.canvas.width / tileWidth)
    height = Math.floor(@stage.canvas.height / tileHeight)

    for name, layer of @layers
      for i in [x..x + width]
        for j in [y..y + height]
          layer.tiles[i]?[j]?.visible = true

  stageMouseUp: (e) =>
    @mouseDown = false

    @lastMouseDown = @gridCoords(e.rawX, e.rawY)

    Minimap.recalculate @newTiles

  stageMouseDown: (e) =>
    @newTiles = []
    @mouseDown = true
    @currentLayer?.addTiles(e.rawX, e.rawY)

  update: ->
    if @toggleGrid
      @grid.visible = @gridOn
      @toggleGrid = false

    if @left
      @move x: -MOVE_DISTANCE
    else if @right
      @move x: MOVE_DISTANCE
    else if @up
      @move y: MOVE_DISTANCE
    else if @down
      @move y: -MOVE_DISTANCE
    if @mouseDown
      @currentLayer?.addTiles(@stage.mouseX, @stage.mouseY)

    @moveHighlight()

  move: (direction) =>
    left = @regX / tileWidth
    right = (Math.floor(@width / tileWidth) * tileWidth + @regX) / tileWidth

    for tiles in _.map(@layers, (l) -> l.tiles)
      if direction.x > 0
        if tiles[left] then for y, tile of tiles[left]
          tile.visible = false

        if tiles[right+1] then for y, tile of tiles[right+1]
          tile.visible = true

      if direction.x < 0
        if tiles[left-1] then for y, tile of tiles[left-1]
          tile.visible = true

        if tiles[right] then for y, tile of tiles[right]
          tile.visible = false

    @regX += direction.x if direction.x
    @regY += direction.y if direction.y

  addGrid: ->
    @grid = new createjs.Container()

    for i in [0..@stage.canvas.width] by tileWidth

      line = new createjs.Shape()
      line.graphics.setStrokeStyle(1)
      line.graphics.beginStroke(GRID_COLOR)
      line.graphics.moveTo(i, 0)
      line.graphics.lineTo(i, @stage.canvas.height)
      @grid.addChild(line)


    for i in [0..@stage.canvas.height] by tileHeight

      line = new createjs.Shape()
      line.graphics.setStrokeStyle(1)
      line.graphics.beginStroke(GRID_COLOR)
      line.graphics.moveTo(0, i)
      line.graphics.lineTo(@stage.canvas.width, i)
      @grid.addChild(line)

    @stage.addChild(@grid)

  # Where in pixel values should the tile be
  worldCoords: (x, y) ->
    x: (x * tileWidth) + @x - @regX
    y: (y * tileHeight) + @y - @regY

  # Where in the tilemap should the tile be
  gridCoords: (x,y) ->
    x:  Math.floor((x + @regX - @x) / tileWidth)
    y:  Math.floor((y + @regY - @y) / tileHeight)

module.exports = new Canvas() # Export a singleton
