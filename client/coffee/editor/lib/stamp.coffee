{tileWidth, tileHeight} = require '../utils'

class Stamp
  constructor: ->
    @tiles = [[0]]

  init: (@game) =>
    # Show on the map what it is going to be placed
    @preview = @game.add.group()

    # Set this to be the bounds of the highlight for calculations
    @bandBounds = {}

    # Just a red border if we are erasing
    @erase = false

    # The border around the preview
    @highlight = @game.add.graphics()

    @setMultiple @tiles

  # Helper method to add a single tile (index) to the stamp
  setSingle: (index) =>
    @setMultiple [[ index ]]

  # indicies should be a 2d array of x, y tile indicies
  setMultiple: (indicies) =>
    @tiles = indicies
    @updatePreview()

  # We are starting a bandfill
  beginBandFill: (x, y) =>
    @initialBandFillPos = {x: x, y: y}

  # Band fill is finished
  endBandFill: =>
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

      # Add all the tiles in the tiles array
      for i in [0..x-1]
        for j in [0..y-1]
          sprite = @game.add.sprite i*tileWidth, j*tileWidth, 'level', @tiles[i][j]
          sprite.alpha = 0.5
          @preview.add sprite

      @changeHighlight x, y

  # Called when the mouse is moved to change position of preview
  updateHighlight: (x, y) =>
    # If this is set, we are in the middle of a fill
    if @initialBandFillPos
      minX = Math.min(@initialBandFillPos.x, x) # top left
      minY = Math.min(@initialBandFillPos.y, y) # top left
      maxX = Math.max(@initialBandFillPos.x, x) # bottom right
      maxY = Math.max(@initialBandFillPos.y, y) # bottom right

      # If we are draging towards top left, we need to add an extra to the max
      maxX++ if maxX is @initialBandFillPos.x
      maxY++ if maxY is @initialBandFillPos.y

      x = minX
      y = minY

      w = @tiles.length
      h = @tiles[0].length

      @bandBounds = {minX: minX, maxX: maxX, minY: minY, maxY: maxY}

      # If we aren't erasing, fill in the preview. Repeat if have multi selected
      if not @erase
        @preview.removeAll()
        for i in [0..(maxX-minX) - 1]
          for j in [0..(maxY-minY) - 1]
            sprite = @game.add.sprite i*tileWidth, j*tileWidth, 'level', @tiles[i%w][j%h]
            @preview.add sprite

      @changeHighlight maxX - minX, maxY - minY

    # Translate to world pos
    @preview.x = x*tileWidth
    @preview.y = y*tileHeight

  setErase: (erase) =>
    @erase = erase
    @updatePreview()

  # Change highlight color depending on which mode we are in
  changeHighlight: (w=1, h=1) =>
    color = if @erase then 0xff0000 else 0xffff00

    @highlight.clear()
    @highlight.lineStyle(2, color, 1)
    @highlight.drawRect 0, 0, w*tileWidth, h*tileHeight
    @preview.add @highlight

module.exports = new Stamp()

