Preload = require '../preload/load'
LevelData = require '../level_data'
Tile = require '../tile'

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

    @undoHistory = []
    @redoHistory = []
    @activeHistory = null

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

    $(window).keyup (e) =>
      if e.keyCode is 68
        @delete = false

    # Tile map!
    data =
      images: [Preload.loader.getResult('level')]
      frames:
        width: @tileWidth
        height: @tileHeight

    @tilesheet = new createjs.SpriteSheet data


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
    @undoHistory.push @activeHistory
    @activeHistory = null

  stageMouseDown: (e) =>
    @activeHistory = []
    @redoHistory = []
    @mouseDown = true
    @addTiles(e.rawX, e.rawY)

  update: ->
    if @_G_DOWN
      @gridOn = not @gridOn
      @grid.visible = @gridOn
      @_G_DOWN = false

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

    for i in [-_x.._x]
      for j in [-_y.._y]
        if @delete then @removeTile(x+i, y+j)
        else @addTile(x+i, y+j, @tile)

  addTile: (x, y, index) ->
    return if @worldCoords(x, y).x < @x
    @tiles[x] ||= {}

    return if (tile = @tiles[x][y])?.tile is index
    t = new Tile(x, y, index, @tilesheet)

    if tile then @removeChild(tile)

    @tiles[x][y] = t
    @addChild t

    @activeHistory.push t

  removeTile: (x, y) ->
    tile = @tiles[x]?[y]
    if tile
      @removeChild(tile)
      delete @tiles[x][y]

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
    return unless (tiles = @undoHistory.pop())
    @redoHistory.push tiles
    for tile in tiles
      @removeTile(tile.pos.x, tile.pos.y)

  redo: ->
    return unless (tiles = @redoHistory.pop())
    @activeHistory = []
    for tile in tiles
      @addTile(tile.pos.x, tile.pos.y, 0)
    @undoHistory.push @activeHistory
    @activeHistory = []

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
