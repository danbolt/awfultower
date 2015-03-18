
cookieParser = require 'cookie-parser'
io = require 'socket.io'
User = require './user'
Auth = require '../auth'

class SocketManager
  constructor: ->

  init: (server, session) ->
    @rooms = {}
    @users = {}

    @io = io.listen server
    @io.use (socket, next) ->
      session socket.request, socket.request.res, next

    @io.on 'connection', (socket) =>
      token = socket.request.session?.usertoken
      Auth.getUsernameFromToken token, (err, username) =>
        username ||= Math.random().toString()
        user = new User username, socket, @

        @users[username] = user
        user.joinRoom 'lobby'

module.exports = new SocketManager()
