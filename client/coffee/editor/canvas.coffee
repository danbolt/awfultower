Preload = require '../preload/load'
LevelData = require './lib/level_data'
Tile = require './lib/tile'
Undo = require './undo'
em = require '../event_manager'

MOVE_DISTANCE =  LevelData.tileWidth
GRID_COLOR = "#e5e5e5"

module.exports = class extends createjs.Container
  constructor: (@delegate) ->
    super
    @tile = 0

    @tiles = {}

    @tileWidth = LevelData.tileWidth
    @tileHeight = LevelData.tileHeight

    @brushSize = 1

    @gridOn = true

    $(window).keydown (e) =>
      if e.keyCode is 68
        @delete = true
      else if e.keyCode is 85
        @undo()
      else if e.keyCode is 82
        @redo()
      if e.keyCode is 71
        @_G_DOWN = true
      if e.keyCode is 16
        @_SHIFT_DOWN = true

    $(window).keyup (e) =>
      if e.keyCode is 68
        @delete = false
      if e.keyCode is 16
        @_SHIFT_DOWN = false

    # Tile map!
    data =
      images: [Preload.loader.getResult('level')]
      frames:
        width: @tileWidth
        height: @tileHeight

    @tilesheet = new createjs.SpriteSheet data

    em.register em.types.toggleGrid, @toggleGrid

    $(window).keydown _.partial(@panKeyChanged, true, _)
    $(window).keyup _.partial(@panKeyChanged, false, _)

    @on 'added', ->
      @width = @stage.canvas.width
      @addHighlight()
      @addGrid()

  toggleGrid: (gridOn) =>
    @gridOn = gridOn
    @toggleGrid = true

  panKeyChanged: (down, e) =>
    if e.keyCode is 72
      @left = down
    else if e.keyCode is 76
      @right = down
    else if e.keyCode is 74
      @up = down
    else if e.keyCode is 75
      @down = down

  changeBrushSize: (size) ->
    @brushSize = size
    @addHighlight()

  moveHighlight: ->

    {x,y} = @gridCoords(@stage.mouseX, @stage.mouseY)
    x *= @tileWidth
    y *= @tileHeight

    @selection.x = x - (@tileWidth * (@brushSize-1))
    @selection.y = y - (@tileHeight * (@brushSize-1))

  # This is the square that highlights which cell you are on
  addHighlight: =>

    @removeChild(@selection) if @selection

    x = Math.floor(@stage.mouseX / @tileWidth) * @tileWidth
    y = Math.floor(@stage.mouseY / @tileHeight) * @tileHeight

    index = @tile

    @selection = new createjs.Container()

    for i in [0..(@brushSize - 1)*2]
      for j in [0..(@brushSize - 1)*2]
        tile = new Tile(i, j, index, @tilesheet)
        tile.alpha = 0.3
        @selection.addChild tile

    @selection.x = x - (@tileWidth * ( @brushSize - 1) )
    @selection.y = y - (@tileHeight * ( @brushSize - 1) )

    g = new createjs.Graphics()
    g.beginStroke("black")
    g.setStrokeStyle(2)
    g.drawRect(0, 0, (@tileWidth * ((@brushSize - 1)*2 + 1)), (@tileHeight * ((@brushSize - 1)*2 + 1)))
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
    @addTiles(e.rawX, e.rawY)

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
      @addTiles(@stage.mouseX, @stage.mouseY)

    {x,y} = @gridCoords(@stage.mouseX, @stage.mouseY)

    @moveHighlight()

  addTiles: (mouseX, mouseY) ->

    {x,y} = @gridCoords(mouseX, mouseY)

    _x = _y = @brushSize - 1

    tilesToAdd = []

    for i in [-_x.._x]
      for j in [-_y.._y]
        tilesToAdd.push(x: x+i, y: y+j)

    if @_SHIFT_DOWN and @lastMouseDown
      if y is @lastMouseDown.y
        for i in [x..@lastMouseDown.x]
          for j in [-_y.._y]
            tilesToAdd.push(x: i, y: y+j) unless {x: i, y: y+j} in tilesToAdd

      else if x is @lastMouseDown.x
        for i in [-_x.._x]
          for j in [y..@lastMouseDown.y]
            tilesToAdd.push(x: x+i, y: j) unless {x: x+i, y: j} in tilesToAdd

    for tile in tilesToAdd
      if @delete then @removeTile(tile.x,tile.y)
      else @addTile(tile.x, tile.y, @tile)


  addTile: (x, y, index, recordHistory = true) ->
    return if @worldCoords(x, y).x < @x
    @tiles[x] ||= {}

    return if (tile = @tiles[x][y])?.tile is index
    t = new Tile(x, y, index, @tilesheet)

    if tile then @removeChild(tile)

    oldIndex = @tiles[x][y]?.tile
    @tiles[x][y] = t
    @addChild t

    Undo.push("+", t, oldIndex) if recordHistory

  removeTile: (x, y, recordHistory = true) ->
    tile = @tiles[x]?[y]
    if tile
      @removeChild(tile)
      delete @tiles[x][y]

      Undo.push("-", tile) if recordHistory

  move: (direction) =>
    left = @regX / @tileWidth
    right = (Math.floor(@width / @tileWidth) * @tileWidth + @regX) / @tileWidth

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
      @addTile undo.x, undo.y, undo.tile, false
    else if undo.action is '-'
      @removeTile undo.x, undo.y, false

  redo: ->
    return unless (redo = Undo.redo())
    if redo.action is '+'
      @addTile redo.x, redo.y, redo.tile, false
    else if redo.action is '-'
      @removeTile redo.x, redo.y, false

  # Where in pixel values should the tile be
  worldCoords: (x, y) ->
    x: (x * @tileWidth) + @x - @regX
    y: (y * @tileWidth) + @y - @regX

  # Where in the tilemap should the tile be
  gridCoords: (x,y) ->
    x:  Math.floor((x + @regX - @x) / @tileWidth)
    y:  Math.floor((y + @regY - @y) / @tileHeight)

  addGrid: ->
    @grid = new createjs.Container()

    for i in [0..@stage.canvas.width] by @tileWidth

      line = new createjs.Shape()
      line.graphics.setStrokeStyle(1)
      line.graphics.beginStroke(GRID_COLOR)
      line.graphics.moveTo(i, 0)
      line.graphics.lineTo(i, @stage.canvas.height)
      @grid.addChild(line)


    for i in [0..@stage.canvas.height] by @tileHeight

      line = new createjs.Shape()
      line.graphics.setStrokeStyle(1)
      line.graphics.beginStroke(GRID_COLOR)
      line.graphics.moveTo(0, i)
      line.graphics.lineTo(@stage.canvas.width, i)
      @grid.addChild(line)

    @stage.addChild(@grid)
