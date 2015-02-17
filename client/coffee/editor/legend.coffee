Preload = require '../preload/load'
Stamp = require './lib/stamp'

{tileWidth, tileHeight} = require './utils'

module.exports = class Legend extends createjs.Container
  constructor: (@delegate) ->
    super
    @x = 0
    @y = 0

    @initial = {}

    data =
      images: [Preload.loader.getResult('level')]
      frames:
        width: tileWidth
        height: tileHeight

    @tilesheet = new createjs.SpriteSheet data

    for i in [0..9]
      for j in [0..7]
        s = new createjs.Sprite @tilesheet
        s.gotoAndStop (index = i*8 + j)
        s.x = j*tileWidth
        s.y = i*tileHeight
        @addChild s

    g = new createjs.Graphics()
    g.beginStroke("black")
    g.setStrokeStyle(2)

    g.drawRect(0, 0, tileWidth, tileHeight)
    @indicator = new createjs.Shape(g)

    @addChild(@indicator)

  stageMouseDown: (e) =>
    x = Math.floor(e.stageX / tileWidth)
    y = Math.floor(e.stageY / tileHeight)

    @initial = {x: x, y: y}

  stageMouseUp: (e) =>

    x = Math.floor(e.stageX / tileWidth)
    y = Math.floor(e.stageY / tileHeight)

    minX = if x <= @initial.x then x else @initial.x
    maxX = if x >= @initial.x then x else @initial.x
    minY = if y <= @initial.y then y else @initial.y
    maxY = if y >= @initial.y then y else @initial.y

    w = Math.floor(@stage.canvas.width / tileWidth)

    if @initial.x is x and @initial.y is y
      Stamp.setSingle y*w + x
    else

      tiles = []
      for i in [minX..maxX]
        _tiles = []
        for j in [minY..maxY]
          _tiles.push j*w + i
        tiles.push _tiles

      Stamp.setMultiple tiles

    @indicator.x = minX * tileWidth
    @indicator.y = minY * tileHeight

    @indicator.graphics.command.w = ((maxX - minX) + 1) * tileWidth
    @indicator.graphics.command.h = ((maxY - minY) + 1) * tileHeight

    @delegate.tileSelected()

