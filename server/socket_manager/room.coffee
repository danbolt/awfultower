module.exports = class Room
  constructor: (@name, @io) ->
    @users = {}

  join: (user) ->
    return unless (socket = user.socket)

    socket.join @name
    user.leaveRoom()

    socket.broadcast.emit(@name).emit 'join_room', _.keys(@users)
    user.room = @

  leave: (user) ->
    socket.leave @name
    socket.broadcast.emit(@name).emit 'leave_room', { uuid: user.username }



