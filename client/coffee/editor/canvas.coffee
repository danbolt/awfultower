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
    # Brush is the type, square, horizontal, vertical
    # BrushSize is how far out it goes in each direction
    @brush = x: 0, y: 0
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

    em.register em.types.brushChanged, (type) =>
      @brush = switch type
        when "square"
          {x: 0, y: 0}
        when "horizontal"
          {x: 1, y: 0}
        when "vertical"
          {x: 0, y: 1}
    em.register em.types.toggleGrid, (gridOn) =>
      @gridOn = gridOn
      @toggleGrid = true

    $(window).keydown _.partial(@panKeyChanged, true, _)
    $(window).keyup _.partial(@panKeyChanged, false, _)

    @on 'added', ->
      @width = @stage.canvas.width
      @addHighlight()
      @addGrid()

  panKeyChanged: (down, e) =>
    if e.keyCode is 72
      @left = down
    else if e.keyCode is 76
      @right = down
    else if e.keyCode is 74
      @up = down
    else if e.keyCode is 75
      @down = down

  # This is the square that highlights which cell you are on
  addHighlight: =>

    if @brush.x is 0 and @brush.y is 0
      _x = _y = @brushSize - 1
    else
      _x = @brush.x * @brushSize
      _y = @brush.y * @brushSize

    return if @stage.mouseX - _x*@tileWidth < @x

    @removeChild(@selection) if @selection

    {x,y} = @gridCoords(@stage.mouseX, @stage.mouseY)
    x *= @tileWidth
    y *= @tileHeight

    x -= _x * @tileWidth
    y -= _y * @tileWidth

    w = @tileWidth * (1+_x*2)
    h = @tileHeight * (1+_y*2)

    g = new createjs.Graphics()
    g.beginStroke("black")
    g.setStrokeStyle(1)
    g.drawRect(x, y, w, h)
    @selection = new createjs.Shape(g)
    @addChild(@selection)

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

    @addHighlight()

  addTiles: (mouseX, mouseY) ->

    {x,y} = @gridCoords(mouseX, mouseY)

    if @brush.x is 0 and @brush.y is 0
      _x = _y = @brushSize - 1
    else
      _x = @brush.x * @brushSize
      _y = @brush.y * @brushSize

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
