Config = require './config'

class ServerAgent
  constructor: ->
    @socket = io()

  send: (event, data) ->
    @socket.emit event, data

  bind: (event, callback) ->
    @socket.on event, (data) ->
      callback data

module.exports = window.server_agent = new ServerAgent()
