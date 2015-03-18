_ = require 'underscore'
fs = require 'fs'
path = require 'path'

dataPath = path.join(require.main.filename, '../data')

module.exports = class Map
  constructor: (@delegate) ->
    @delegate.socket.on 'load_map',
      _.bind(@loadMap, @delegate)
    @delegate.socket.on 'new_map',
      _.bind(@newMap, @delegate)
    @delegate.socket.on 'add_tile',
      _.bind(@addTile, @delegate)

  loadMap: (data) ->
    room = data.filename

    @joinRoom room

    # check if filename passed in exists in our filesystem
    fs.exists path.join(dataPath, room), (exists) =>
      return unless exists

      fs.readFile path.join(dataPath, room), (err, map_buffer) =>
        return cb(err) if err
        map_array = map_buffer.toString().split ','

        @socket.emit 'load_map', { map:map_array }

  newMap: (data) ->

    # after map size has been retrieved, build map of 0's in x by y dimensions
    map_array = []
    for i in [0...(data.y)]
      map_array[i] = []
      for j in [0...(data.x)]
        map_array[i][j] = ''

    # TODO make async eventually
    fs.writeFile path.join(dataPath, @room), map_array.toString(), (err) =>
      return cb(err) if err

      loadMap {filename: @filename}, @socket

  addTile: (data) ->
    fs.exists path.join(dataPath, @room), (exists) =>
      return unless exists

      fs.readFile path.join(dataPath, @room), (err, map_buffer) =>
        return cb(err) if err

        map_array = map_buffer.toString().split ','

        # assign tile type to the provided index
        # using 1-D array as 2-D using formula:
        #     (data.y*data.map_x) + data.x
        # this allows for easy CSV storage
        map_array[(data.y*data.map_x) + data.x] = data.index

        fs.writeFile path.join(dataPath, @room), map_array.toString(), (err) =>
          return cb(err) if err

          if data.index is ''
            data.index = '-1'

          # emit to all user in room
          @broadcast 'add_tile', data


