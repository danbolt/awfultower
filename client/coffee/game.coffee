Preload = require './preload/load'
Level = require './level'
Editor = require './editor'

class Game
  constructor: ->
    Preload.start @loadComplete
    @throttle = 0

  loadComplete: =>
    @stage = new createjs.Stage 'canvas'

    @editor = new Editor @
    @editor.show()

    createjs.Ticker.addEventListener 'tick', @stage
    createjs.Ticker.addEventListener 'tick', @tick
    createjs.Ticker.framerate = 60

  tick: (e) =>
    @scene.update()
    @stage.update()

  showScene: (scene) =>
    @stage.removeChild @scene
    @stage.addChild scene
    @scene = scene

module.export = new Game()

