cookieParser = require 'cookie-parser'
config = require 'config'
io = require 'socket.io'
User = require './user'
Auth = require '../app/auth'

class SocketManager
  constructor: ->
  init: (server, session) ->

    io = io.listen server
    io.use (socket, next) ->
      session socket.request, socket.request.res, next

    @users = []
    io.on 'connection', (socket) =>
      token = socket.request.session?.usertoken
      Auth.getUsernameFromToken token, (err, username) =>
        username ||= Math.random().toString()
        @users[username] = new User socket, username, io


module.exports = new SocketManager()
