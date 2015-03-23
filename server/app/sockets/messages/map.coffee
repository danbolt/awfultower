_ = require 'underscore'
fs = require 'fs'
path = require 'path'

db = require '../../../db'

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
    name = data.map

    db.collection("map").findOne {name: name}, (err, map) =>
      return console.log "Error loading map", err if err
      return console.log "No map found with name: #{name}" unless map

      @joinRoom name
      dataFile = map.dataFile

      # check if filename passed in exists in our filesystem
      fs.exists path.join(dataPath, dataFile), (exists) =>
        return unless exists

        fs.readFile path.join(dataPath, dataFile), "utf-8", (err, data) =>
          return console.log "Error loading map", err if err
          return console.log "No data" unless data
          mapData = JSON.parse(data)

          @socket.emit 'load_map',
            map: mapData
            width: map.width
            height: map.height

  newMap: (data) ->
    return unless data.name and data.width and data.height

    maps = db.collection 'map'

    mapData =
      name: data.name
      width: data.width
      height: data.height
      dataFile: data.name

    maps.findOne {name: data.name}, (err, map) ->
      return console.log "Map already exists with name: #{data.name}" if map

      maps.insert mapData, (err, map) =>
        return console.log(err) if err
        return console.log("Map failed to be created") unless map

  addTile: (data) ->

    add = (array) =>
      # assign tile type to the provided index
      # using 1-D array as 2-D using formula:
      #     (data.y*data.map_x) + data.x
      # this allows for easy CSV storage
      array[(data.y*data.map_x) + data.x] = data.index

      fs.writeFile path.join(dataPath, @room), JSON.stringify(array), (err) =>
        return cb(err) if err

        # emit to all user in room
        @broadcast 'add_tile', data

    fs.exists path.join(dataPath, @room), (exists) =>
      if exists
        fs.readFile path.join(dataPath, @room), "utf-8", (err, map_buffer) =>
          return cb(err) if err

          map_array = if map_buffer
            JSON.parse map_buffer
          else []

          add(map_array)
      else add []
