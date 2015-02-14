Preload = require '../preload/load'
Tile = require './lib/tile'
Undo = require './undo'
Layer = require './lib/layer'
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

    @gridOn = true

    em.register 'keydown', @keydown
    em.register 'keyup', @keyup
    em.register 'toggle-grid', @toggleGrid
    em.register 'toggle-erase', @toggleErase
    em.register 'add-layer', @addLayer
    em.register 'change-layer', @changeLayer
    em.register 'hide-layer', @hideLayer
    em.register 'lock-layer', @lockLayer

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

  addLayer: (name) =>
    @currentLayer = new Layer(@, name)
    @layers[name] = @currentLayer
    @addChild(@currentLayer)

  keydown: (e) =>
    switch e.keyCode
      when 85 # u
        @undo()
      when 82 # r
        @redo()
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

  stageMouseUp: (e) =>
    @mouseDown = false

    @lastMouseDown = @gridCoords(e.rawX, e.rawY)

  stageMouseDown: (e) =>
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

    if direction.x > 0
      if @tiles[left] then for y, tile of @tiles[left]
        tile.visible = false

      if @tiles[right+1] then for y, tile of @tiles[right+1]
        tile.visible = true

    if direction.x < 0
      if @tiles[left-1] then for y, tile of @tiles[left-1]
        tile.visible = true

      if @tiles[right] then for y, tile of @tiles[right]
        tile.visible = false

    @regX += direction.x if direction.x
    @regY += direction.y if direction.y

  undo: ->
    return unless (undo = Undo.undo())
    if undo.action is '+'
      @currentLayer.addTile undo.x, undo.y, undo.tile, false
    else if undo.action is '-'
      @currentLayer.removeTile undo.x, undo.y, false

  redo: ->
    return unless (redo = Undo.redo())
    if redo.action is '+'
      @currentLayer.addTile redo.x, redo.y, redo.tile, false
    else if redo.action is '-'
      @currentLayer.removeTile redo.x, redo.y, false

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
    y: (y * tileWidth) + @y - @regX

  # Where in the tilemap should the tile be
  gridCoords: (x,y) ->
    x:  Math.floor((x + @regX - @x) / tileWidth)
    y:  Math.floor((y + @regY - @y) / tileHeight)

module.exports = new Canvas() # Export a singleton
