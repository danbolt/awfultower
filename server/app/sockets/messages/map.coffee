_ = require 'underscore'
fs = require 'fs'
path = require 'path'
async = require 'async'

DB = require '../../../db'
dataPath = path.join(require.main.filename, '../data')

ObjectId = require('mongodb').ObjectID

module.exports = class Map
  constructor: (@delegate) ->
    @currentLayer = null

    @layers = DB.collection 'layer'
    @maps = DB.collection 'map'

    @delegate.socket.on 'load_map', @loadMap
    @delegate.socket.on 'add_tile', @addTile
    @delegate.socket.on 'add_layer', @addLayer
    @delegate.socket.on 'remove_tile', @removeTile

  getMap: =>
    matcher = /map=([a-zA-Z-0-9\_\-]+)/
    ref = @delegate.socket.handshake.headers.referer

    map = ref.match(matcher)?[1]

    if map
      ObjectId map
    else null

  userCanAccessMap: (cb) =>
    map = @getMap()

    @maps.findOne {_id: map}, (err, map) =>
      return cb "Error loading map", err if err
      return cb "No map found with name: #{name}" unless map

      users = map.users
      unless users and (@delegate.username in users)
        return cb "You do not have permission to that map"
      else
        cb(null, map)

  loadMap: (data) =>
    async.waterfall [
      @userCanAccessMap
      (map, cb) =>

        if map.layers
          @layers.find({_id: {$in: map.layers}}).toArray (err, layers) =>
            return cb "Error loading layers", err if err
            cb(null, map, layers)
        else
          cb(null, map, [])

      (map, layers, cb) =>
        data =
          width: map.width
          height: map.height
          name: map.name
          layers: layers

        @delegate.joinRoom map.name
        @delegate.socket.emit 'load_map', data

        cb()

    ], (err, result) =>
      return console.log err if err

  addLayer: (data) =>
    async.waterfall [
      @userCanAccessMap
      (map, cb) =>
        name = data.name
        return cb "No name specified to create layer" unless name

        @layers.insert {name: name}, (err, layer) =>
          return cb "Error saving layer", err if err
          return cb "Layer failed to be created" unless layer?.ops?[0]

          id = layer.ops[0]._id
          cb(null, map, id)

      (map, layerId, cb) =>
          @maps.update {_id: map._id}, {$push: {layers: layerId}}, (err, result) =>
            return cb "Could not push new layer to map", err if err
            cb()

    ], (err, result) =>
      return console.log err if err

  # Batch up changes, clear the interval whenever anything changes. After 2000
  # seconds (of inactivity), write the changes
  addTile: (data) =>
    async.waterfall [
      @userCanAccessMap
      (map, cb) =>

        return cb "No id specified" unless (id = ObjectId(data.layerId))

        property = "data.#{data.x}.#{data.y}"

        obj = {}
        obj[property] = data.index

        @layers.update {_id: id}, {$set: obj}
        cb()

      (cb) =>
        @delegate.broadcast 'add_tile', data
        cb()

    ], (err, result) =>
      return console.log err if err

  # Remove the tile in the database
  removeTile: (data) =>
    async.waterfall [
      @userCanAccessMap
      (map, cb) =>

        return cb "No id specified" unless (id = ObjectId(data.layerId))

        property = "data.#{data.x}.#{data.y}"

        obj = {}
        obj[property] = ""

        @layers.update {_id: id}, {$unset: obj}
        cb()

      (cb) =>
        @delegate.broadcast 'remove_tile', data
        cb()

    ], (err, result) =>
      return console.log err if err
