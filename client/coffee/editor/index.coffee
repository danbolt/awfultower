Legend = require './legend'
Canvas = require './canvas'
Preload = require '../preload/load'
em = require '../event_manager'

GRID_COLOR = "#e5e5e5"

module.exports = class Editor
  constructor: (@delegate) ->

    @legendStage = new createjs.Stage 'legend-canvas'
    @sceneStage = new createjs.Stage 'scene-canvas'

    @legend = new Legend(@)
    Canvas.init()

    @legendStage.addChild @legend
    @sceneStage.addChild Canvas

    em.register 'keydown', @keydown

    @sceneStage.on 'stagemousedown', Canvas.stageMouseDown
    @sceneStage.on 'stagemouseup', Canvas.stageMouseUp

    # @addBrushControls()
    # @addGrid()

    createjs.Ticker.addEventListener 'tick', @legendStage
    createjs.Ticker.addEventListener 'tick', @sceneStage
    createjs.Ticker.addEventListener 'tick', @update
    createjs.Ticker.framerate = 60


  keydown: (e) =>
    if 48 < e.keyCode <= 57 # 48 is 0, 57 is 9
      Canvas.changeBrushSize e.keyCode - 48

  update: =>
    Canvas.update()

  tileSelected: (index) =>
    Canvas.changeTile index

