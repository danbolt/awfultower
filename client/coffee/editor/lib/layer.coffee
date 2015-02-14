Undo = require '../undo'
Tile = require './tile'

module.exports = class Layer extends createjs.Container
  constructor: (@delegate, @name) ->
    super

    @tiles = {}

  addTiles: (mouseX, mouseY) ->
    return if not @visible or @locked

    {x,y} = @delegate.gridCoords(mouseX, mouseY)

    _x = _y = @delegate.brushSize - 1

    tilesToAdd = []

    for i in [-_x.._x]
      for j in [-_y.._y]
        tilesToAdd.push(x: x+i, y: y+j)

    if @delegate._SHIFT_DOWN and @delegate.lastMouseDown
      if y is @delegate.lastMouseDown.y
        for i in [x..@delegate.lastMouseDown.x]
          for j in [-_y.._y]
            tilesToAdd.push(x: i, y: y+j) unless {x: i, y: y+j} in tilesToAdd

      else if x is @delegate.lastMouseDown.x
        for i in [-_x.._x]
          for j in [y..@delegate.lastMouseDown.y]
            tilesToAdd.push(x: x+i, y: j) unless {x: x+i, y: j} in tilesToAdd

    for tile in tilesToAdd
      if @delegate.erase then @removeTile(tile.x,tile.y)
      else @addTile(tile.x, tile.y, @delegate.tile)


  addTile: (x, y, index, recordHistory = true) ->

    return if not @visible or @locked
    return if @delegate.worldCoords(x, y).x < @x

    @tiles[x] ||= {}

    return if (tile = @tiles[x][y])?.tile is index
    t = new Tile(x, y, index, @delegate.tilesheet)

    if tile then @removeChild(tile)

    oldIndex = @tiles[x][y]?.tile
    @tiles[x][y] = t
    @addChild t

    Undo.push("+", t, oldIndex) if recordHistory

  removeTile: (x, y, recordHistory = true) ->
    return if not @visible or @locked

    tile = @tiles[x]?[y]
    if tile
      @removeChild(tile)
      delete @tiles[x][y]

      Undo.push("-", tile) if recordHistory
