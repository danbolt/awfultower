Preload = require '../preload/load'
LevelData = require '../level_data'
Tile = require '../tile'

MOVE_DISTANCE =  LevelData.tileWidth

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

    @tilesX = {}
    @tilesY = {}

    $(window).keydown (e) =>
      if e.keyCode is 68
        @delete = true

    $(window).keyup (e) =>
      if e.keyCode is 68
        @delete = false

    # Tile map!
    data =
      images: [Preload.loader.getResult('level')]
      frames:
        width: @tileWidth
        height: @tileHeight
        margin: 1
        spacing: 1

    @tilesheet = new createjs.SpriteSheet data

    @addHighlight()

    $(window).keydown _.partial(@panKeyChanged, true, _)
    $(window).keyup _.partial(@panKeyChanged, false, _)

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

    stage = @delegate.delegate.stage
    return if stage.mouseX - _x*@tileWidth < @x

    @removeChild(@selection) if @selection

    {x,y} = @gridCoords(stage.mouseX, stage.mouseY)
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

  stageMouseDown: (e) =>
    @mouseDown = true
    @addTiles(e.rawX, e.rawY)

  update: ->
    if @left
      @move x: -MOVE_DISTANCE
    else if @right
      @move x: MOVE_DISTANCE
    else if @up
      @move y: MOVE_DISTANCE
    else if @down
      @move y: -MOVE_DISTANCE
    stage = @delegate.delegate.stage
    if @mouseDown
      @addTiles(stage.mouseX, stage.mouseY)

    {x,y} = @gridCoords(stage.mouseX, stage.mouseY)

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

    @tilesX[x] ||= []
    @tilesY[y] ||= []


    return if (tile = @tiles[x][y])?.tile is index
    t = new Tile(x, y, index, @tilesheet)

    if tile then @removeChild(tile)

    @tilesX[x].push(t)
    @tilesY[y].push(t)

    @tiles[x][y] = t
    @addChild t

  removeTile: (x, y) ->
    tile = @tiles[x]?[y]
    if tile
      @removeChild(tile)
      delete @tiles[x][y]

  move: (direction) =>
    left = @regX / @tileWidth
    right = (Math.floor(@width / @tileWidth) * @tileWidth + @regX) / @tileWidth

    if direction.x > 0
      if @tilesX[left] then for tile in @tilesX[left]
        tile.visible = false

      if @tilesX[right+1] then for tile in @tilesX[right+1]
        tile.visible = true

    if direction.x < 0
      if @tilesX[left-1] then for tile in @tilesX[left-1]
        tile.visible = true

      if @tilesX[right] then for tile in @tilesX[right]
        tile.visible = false

    @regX += direction.x if direction.x
    @regY += direction.y if direction.y


  # Where in pixel values should the tile be
  worldCoords: (x, y) ->
    x: (x * @tileWidth) + @x - @regX
    y: (y * @tileWidth) + @y - @regX

  # Where in the tilemap should the tile be
  gridCoords: (x,y) ->
    x:  Math.floor((x + @regX - @x) / @tileWidth)
    y:  Math.floor((y + @regY - @y) / @tileHeight)


