{tileWidth, tileHeight} = require '../utils'

class Stamp extends Phaser.Group
  constructor: ->
    @tiles = [[0]]

  init: (@game) =>
    @preview = @game.add.group()

    @bandBounds = {}
    @erase = false

    @highlight = @game.add.graphics()
    @setMultiple @tiles

  setSingle: (index) =>
    @setMultiple [[ index ]]

  setMultiple: (indicies) =>
    @tiles = indicies
    @updatePreview()

  updatePreview: ->
    @preview.removeAll()

    if @erase
      @changeHighlight()
    else
      x = @tiles.length
      y = @tiles[0].length

      @preview.removeAll()

      for i in [0..x-1]
        for j in [0..y-1]
          sprite = @game.add.sprite i*tileWidth, j*tileWidth, 'level', @tiles[i][j]
          sprite.alpha = 0.5
          @preview.add sprite

      @changeHighlight x, y

  beginBandFill: (x, y) =>
    @initialBandFillPos = {x: x, y: y}

  endBandFill: =>
    @initialBandFillPos = null
    @bandBounds = {}
    @updatePreview()

  # Called when the mouse is moved to change position of preview
  updateHighlight: (x, y) =>
    if @initialBandFillPos
      minX = Math.min(@initialBandFillPos.x, x)
      maxX = Math.max(@initialBandFillPos.x, x)
      minY = Math.min(@initialBandFillPos.y, y)
      maxY = Math.max(@initialBandFillPos.y, y)

      maxX++ if maxX is @initialBandFillPos.x
      maxY++ if maxY is @initialBandFillPos.y

      x = minX
      y = minY

      w = @tiles.length
      h = @tiles[0].length

      @bandBounds = {minX: minX, maxX: maxX, minY: minY, maxY: maxY}

      if not @erase
        @preview.removeAll()
        for i in [0..(maxX-minX) - 1]
          for j in [0..(maxY-minY) - 1]
            sprite = @game.add.sprite i*tileWidth, j*tileWidth, 'level', @tiles[i%w][j%h]
            @preview.add sprite

      @changeHighlight maxX - minX, maxY - minY

    @preview.x = x*tileWidth
    @preview.y = y*tileHeight

  setErase: (erase) =>
    @erase = erase
    @updatePreview()

  changeHighlight: (w=1, h=1) =>
    color = if @erase then 0xff0000 else 0xffff00

    @highlight.clear()
    @highlight.lineStyle(2, color, 1)
    @highlight.drawRect 0, 0, w*tileWidth, h*tileHeight
    @preview.add @highlight

module.exports = new Stamp()

