_ = require 'underscore'
fs = require 'fs'
path = require 'path'

db = require '../../../db'

dataPath = path.join(require.main.filename, '../data')

module.exports = class Map
  constructor: (@delegate) ->
    @delegate.socket.on 'load_map', @loadMap
    @delegate.socket.on 'add_tile', @addTile

    @data = {}

  loadMap: (data) =>
    name = data.map

    db.collection("map").findOne {name: name}, (err, map) =>
      return console.log "Error loading map", err if err
      return console.log "No map found with name: #{name}" unless map

      @delegate.joinRoom name
      dataFile = map.dataFile

      # check if filename passed in exists in our filesystem
      fs.exists path.join(dataPath, dataFile), (exists) =>
        return unless exists

        fs.readFile path.join(dataPath, dataFile), "utf-8", (err, data) =>
          return console.log "Error loading map", err if err
          return console.log "No data" unless data
          mapData = JSON.parse(data)

          @delegate.socket.emit 'load_map',
            map: mapData
            width: map.width
            height: map.height

  # Actually write the changes
  writeChanges: =>
    # Stores which elements are actually being added. Don't delete anything
    # until we know things have succeeded
    deleted = []
    clearInterval @timer

    add = (array) =>
      for index, tile of @data
        array[index] = tile
        deleted.push index

      fs.writeFile path.join(dataPath, @delegate.room), JSON.stringify(array), (err) =>
        return cb(err) if err

        # Only delete the elements from the data array after they are added
        delete @data[index] for index in deleted

        data = {type: 'info', message: "Saved"}

        # Notify users that it has saved
        @delegate.broadcast "toast", data
        @delegate.socket.emit "toast", data

    # Figure out what the current data array looks like
    fs.exists path.join(dataPath, @delegate.room), (exists) =>
      if exists
        fs.readFile path.join(dataPath, @delegate.room), "utf-8", (err, map_buffer) =>
          return cb(err) if err

          map_array = if map_buffer
            JSON.parse map_buffer
          else []

          add(map_array)
      else add []

  # Batch up changes, clear the interval whenever anything changes. After 2000
  # seconds (of inactivity), write the changes
  addTile: (data) =>
    # Get the position in the 1d array from the x,y values
    index = (data.y*data.map_x) + data.x

    @data[index] = data.index
    @delegate.broadcast 'add_tile', data

    clearInterval @timer if @timer
    @timer = setInterval @writeChanges, 2000


