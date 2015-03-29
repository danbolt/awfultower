Config = require './config'

class ServerAgent
  constructor: ->
    @counter = 0
    @socket = io()

    @promises = {}

    # We sent a message to the server that expects a response
    @socket.on 'response', (data) =>
      return unless (id = data.responseId)?
      @promises[id]?(data.err, data)

      delete @promises[id]

  send: (event, data, cb) =>
    # If there is a cb passed in, we want something to happen when the server
    # code executes. Queue up the callback
    if cb?
      id = @counter
      @promises[id] = cb

      data.responseId = id
      @counter++

    @socket.emit event, data

  bind: (event, callback) ->
    @socket.on event, (data) ->
      callback data

module.exports = window.server_agent = new ServerAgent()
