Tile = require './tile'
Undo = require '../undo'
Stamp = require './stamp'

module.exports = class Layer extends createjs.Container
  constructor: (@delegate, @name) ->
    super

    @tiles = {}

    @bounds =
      x: {min: 9999, max: -9999}
      y: {min: 9999, max: -9999}

    @_undo = new Undo()

  width: =>
    @bounds.x.max - @bounds.x.min

  height: =>
    @bounds.y.max - @bounds.y.min

  # Make sure that the tile is inside the viewport!
  outsideViewport: (x, y) ->
    {x,y} = @delegate.worldCoords(x, y)
    w = @delegate.stage.canvas.width
    h = @delegate.stage.canvas.height

    return not ( 0 <= x < w and 0 <= y < h )

  addTiles: (mouseX, mouseY) ->
    return if not @visible or @locked

    {x,y} = @delegate.gridCoords(mouseX, mouseY)

    tilesToAdd = []

    if Stamp.multiple
      for i in [0..Stamp.indicies.length - 1]
        for j in [0..Stamp.indicies[i].length - 1]

          @addTile(x+i,y+j, Stamp.indicies[i][j])
    else
      index = Stamp.index

      _x = _y = @delegate.brushSize - 1

      # Add basic tiles
      for i in [-_x.._x]
        for j in [-_y.._y]
          tilesToAdd.push(x: x+i, y: y+j)

      # If you are holding shift, add tiles in a straight line
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
        else @addTile(tile.x, tile.y, index)

  addTile: (x, y, index, recordHistory = true) ->

    return if not @visible or @locked
    return if @outsideViewport x, y

    @tiles[x] ||= {}

    return if (tile = @tiles[x][y])?.tile is index
    t = new Tile(x, y, index, @delegate.tilesheet)

    if tile then @removeChild(tile)

    oldIndex = @tiles[x][y]?.tile
    @tiles[x][y] = t
    @addChild t

    @bounds.x.min = x if x < @bounds.x.min
    @bounds.x.max = x + 1 if x + 1 > @bounds.x.max

    @bounds.y.min = y if y < @bounds.y.min
    @bounds.y.max = y + 1 if y + 1 > @bounds.y.max

    @_undo.push("+", t, oldIndex) if recordHistory

    @delegate.newTiles.push t

  removeTile: (x, y, recordHistory = true) =>
    return if not @visible or @locked

    tile = @tiles[x]?[y]
    if tile
      @removeChild(tile)
      delete @tiles[x][y]

      @_undo.push("-", tile) if recordHistory
      @delegate.newTiles.push tile

  undo: ->
    return unless (undo = @_undo.undo())
    if undo.action is '+'
      @addTile undo.x, undo.y, undo.tile, false
    else if undo.action is '-'
      @removeTile undo.x, undo.y, false

  redo: ->
    return unless (redo = @_undo.redo())
    if redo.action is '+'
      @addTile redo.x, redo.y, redo.tile, false
    else if redo.action is '-'
      @removeTile redo.x, redo.y, false

