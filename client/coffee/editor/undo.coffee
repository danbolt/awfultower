# A pretty straight forward undo/redo history.
# Events are grouped together, for example a mouse down -> move -> up sequence
# would mean that every tile added in between down and up is in one event
module.exports = class Undo
  constructor: (@delegate) ->
    @_undo = []
    @_redo = []

  # Add an item to the undo stack. When you do this, clear the redo stack
  push: (action, tiles) ->
    @_redo = []
    _tiles = []
    for x, ys of tiles
      for y, tile of ys
        _tiles.push _.extend(tile, {x: x, y: y})

    @_undo.push {action: action, tiles: _tiles}

  # Undo an event, push that event onto the redo stack
  undo: ->
    return unless (item = @_undo.pop())
    @performAction item
    @_redo.push @swap item

  # Redo an event, push that event onto the undo stack
  redo: ->
    return unless (item = @_redo.pop())
    @performAction item
    @_undo.push @swap item

  # Perform the undo/redo action. Just do the opposite of the initial event
  performAction: (item) ->
    action = item.action
    for t in item.tiles
      if action is '-'
        @delegate.addTile t.previous, t.x, t.y, t.layer, false
      if action is '+'
        if t.previous?
          @delegate.addTile t.previous, t.x, t.y, t.layer, false
        else
          @delegate.removeTile t.x, t.y, t.layer, false

  # turns an add-item into a remove-item and vice versa by switching the action
  # and swapping tile.index <-> tile.previous for each tile
  swap: (item) ->
    item.action = if item.action is '+' then '-' else '+'
    for tile in item.tiles
      prev = tile.previous
      tile.previous = tile.index
      tile.index = prev
    item
