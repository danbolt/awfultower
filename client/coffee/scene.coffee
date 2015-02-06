module.exports = class extends createjs.Container
  constructor: (@delegate) ->
    super
    @container = new createjs.Container()

  show: ->
    @delegate.showScene @
