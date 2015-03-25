# The stamp shows a preview of what tiles are selected, or where the user
# is dragging / filling. It also holds the bounds which are used for actually
# adding the changes to the map

ServerAgent = require '../server_agent'

{tileWidth, tileHeight} = require '../utils'

class Stamp
  constructor: ->
    @tiles = [[0]]

  init: (@game) =>
    # Set this to be the bounds of the highlight for calculations
    @bandBounds = {}

    @erase = false

    # Show on the map what it is going to be placed
    @preview = @game.add.group()

    # The border around the preview
    @highlight = @game.add.graphics()

    @setMultiple @tiles

  # Helper method to add a single tile (index) to the stamp
  setSingle: (index) ->
    @setMultiple [[ index ]]

  # indicies should be a 2d array of x, y tile indicies
  setMultiple: (indicies) ->
    @tiles = indicies
    @updatePreview()

  beginBandFill: (x, y) ->
    @initialBandFillPos = {x: x, y: y}

  endBandFill: ->
    @initialBandFillPos = null
    @bandBounds = {}
    @updatePreview()

  # Updates the tiles in a preview
  updatePreview: ->
    @preview.removeAll()

    # Erase mode only has a border, no preview
    if @erase
      @changeHighlight()
    else
      x = @tiles.length
      y = @tiles[0].length

      # A bit of a hack...just remove all the tiles all the time
      @preview.removeAll()

      for i in [0..x - 1]
        for j in [0..y - 1]
          tile = @tiles[i][j]
          sprite = @game.add.sprite i * tileWidth, j * tileWidth, 'level', tile
          sprite.alpha = 0.5
          @preview.add sprite

      @changeHighlight x, y

  # Called when the mouse is moved to change position of preview
  updateHighlight: (x, y) ->
    # If this is set, we are in the middle of a fill
    if @initialBandFillPos
      minX = Math.min(@initialBandFillPos.x, x) # top left
      minY = Math.min(@initialBandFillPos.y, y) # top left
      maxX = Math.max(@initialBandFillPos.x, x) # bottom right
      maxY = Math.max(@initialBandFillPos.y, y) # bottom right

      x = minX
      y = minY

      w = @tiles.length
      h = @tiles[0].length

      @bandBounds = { minX: minX, maxX: maxX, minY: minY, maxY: maxY }

      # If we aren't erasing, fill in the preview. Repeat if have multi selected
      if not @erase
        @preview.removeAll()
        for i in [0..maxX - minX]
          for j in [0..maxY - minY]
            tile = @tiles[i % w][j % h]
            sprite = @game.add.sprite i * tileWidth, j * tileWidth, 'level', tile
            @preview.add sprite

      @changeHighlight (maxX - minX) + 1, (maxY - minY) + 1

    # Translate to world pos
    @preview.x = x * tileWidth
    @preview.y = y * tileHeight

    ServerAgent.send 'stamp_move', {uuid: "", x: x, y: y}

  setErase: (erase) ->
    @erase = erase
    @updatePreview()

  # Change highlight color depending on which mode we are in
  changeHighlight: (w = 1, h = 1) ->
    color = if @erase then 0xff0000 else 0xffff00

    @highlight.clear()
    @highlight.lineStyle 1, color, 1
    @highlight.drawRect 0, 0, w * tileWidth, h * tileHeight
    @preview.add @highlight

module.exports = new Stamp()

