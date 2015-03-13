io = require 'socket.io'
path = require 'path'
fs = require 'fs'

class SocketManager
  constructor: ->
  init: (server) ->

    io = io.listen server

    @filename = ""

    io.on 'connection', (@socket) =>
      @socket.on 'load_map', @loadMap
      @socket.on 'new_map', @newMap
      @socket.on 'add_tile', @addTile
      @socket.on 'stamp_move', @stampMove

  stampMove: (data) =>

    # {uuid: USERNAME, x:x, y:y}
    socket.emit 'stamp_move', data

  loadMap: (data) =>

    # leave user's current map room
    @socket.leave @filename

    # bind current map name to @socket (or future user class)
    @filename = data.filename

    # join new room for current map
    @socket.join data.filename

    # check if filename passed in exists in our filesystem
    if not fs.existsSync path.join __dirname, '../..', 'server/data/' + @filename
      # if it doesn't exist, ask client for map size
      # this will callback to our 'new_map' binding
      @socket.emit 'get_new_map'
    else
      # map does exist, load into buffer
      map_buffer = fs.readFileSync path.join __dirname, '../..','server/data/', data.filename

      # cast buffer to string, and then split by commad to generate our array
      map_array = map_buffer.toString().split ','

      # emit load map call to client with array being sent through @socket
      @socket.emit 'load_map', { map:map_array }

  newMap: (data) =>

    # after map size has been retrieved, build map of 0's in x by y dimensions
    map_array = []
    for i in [0...(data.y)]
      map_array[i] = []
      for j in [0...(data.x)]
        map_array[i][j] = ''

    # TODO make async eventually
    fs.writeFileSync (path.join __dirname, '../..','server/data/' + @filename), map_array.toString()

    loadMap {filename: @filename}, @socket

  addTile: (data) =>

    if fs.existsSync path.join __dirname, '../..', 'server/data/' + @filename
      # read in our map file to buffer
      map_buffer = fs.readFileSync path.join __dirname, '../..','server/data/' + @filename

      # cast buffer to string, and then split by commad to generate our array
      map_array = map_buffer.toString().split ','

      # assign tile type to the provided index
      # using 1-D array as 2-D using formula:
      #     (data.y*data.map_x) + data.x
      # this allows for easy CSV storage
      map_array[(data.y*data.map_x) + data.x] = data.index

      # write our array cast as string to file in our filesystem
      fs.writeFileSync (path.join __dirname, '../..','server/data/' + @filename), map_array.toString()

      if data.index is ''
        data.index = '-1'

      # emit to all user in room
      io.to(@filename).emit 'add_tile', data

module.exports = new SocketManager()
