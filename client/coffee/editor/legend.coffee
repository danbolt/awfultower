Preload = require '../preload/load'
LevelData = require '../level_data'

module.exports = class Legend extends createjs.Container
  constructor: (@delegate) ->
    super
    @x = 0
    @y = 0
    @tileWidth = LevelData.tileWidth
    @tileHeight = LevelData.tileHeight

    data =
      images: [Preload.loader.getResult('level')]
      frames:
        width: @tileWidth
        height: @tileHeight

    @tilesheet = new createjs.SpriteSheet data

    for i in [0..9]
      for j in [0..7]
        s = new createjs.Sprite @tilesheet
        s.gotoAndStop (index = i*8 + j)
        s.on 'click', _.partial(@tileSelected, i, j, index)
        s.x = j*@tileWidth
        s.y = i*@tileHeight
        @addChild s


    g = new createjs.Graphics()
    g.beginStroke("black")
    g.setStrokeStyle(2)

    g.drawRect(0, 0, @tileWidth, @tileHeight)
    @indicator = new createjs.Shape(g)

    @addChild(@indicator)

  tileSelected: (i, j, index) =>
    @indicator.x = j * @tileWidth
    @indicator.y = i * @tileHeight
    @delegate.tileSelected(index)

