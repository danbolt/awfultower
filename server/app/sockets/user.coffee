_ = require 'underscore'
{Stamp, Map, Tilesheet} = require './messages'

module.exports = class user
  constructor: (@username, @socket, @delegate) ->
    @room = null
    new Stamp @
    new Map @
    new Tilesheet @

  broadcast: (message, data) ->
    @socket.broadcast.emit message, data

  broadcastWithSender: (message, data) ->
    @socket.broadcast.emit message, data
    @socket.emit message, data

  joinRoom: (room) ->
    @socket.leave @room
    @socket.join room
    @room = room

    @broadcast 'user_joined', {uuid: @username}
    @socket.emit 'join_room', {users: _.without @delegate.rooms[room], @username}

    @delegate.rooms[room] ||= []
    @delegate.rooms[room].push @username

  leaveRoom: ->
    return unless @room
    @socket.broadcast.emit @room.name, {username: @username}

