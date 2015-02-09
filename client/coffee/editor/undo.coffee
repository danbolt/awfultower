class Undo
  constructor: ->
    @_undo = []
    @_redo = []

  push: (action, tile, old) ->
    @_redo = []
    {x,y} = tile.pos
    index = tile.tile
    item =
      x: x
      y: y
      action: action
      tileIndex: index

    item.previousTileIndex = old if old?
    @_undo.push item

  undo: ->
    return null unless (item = @_undo.pop())
    @_redo.push item
    params = {x: item.x, y: item.y}

    if item.previousTileIndex? and item.action is '+'
      params.action = '+'
      params.tile = item.previousTileIndex
    else if item.action is '+'
      params.action = '-'
    else if item.action is '-'
      params.action = '+'
      params.tile = item.tileIndex

    params

  redo: ->
    return null unless (item = @_redo.pop())
    @_undo.push item

    action: item.action
    x: item.x
    y: item.y
    tile: item.tileIndex


module.exports = new Undo()
