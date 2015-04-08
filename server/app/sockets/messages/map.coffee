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
    @delegate.socket.on 'new_map', @newMap
    @delegate.socket.on 'get_maps', @getMaps
    @delegate.socket.on 'remove_layer', @deleteLayer
    @delegate.socket.on 'rename_layer', @renameLayer
    @delegate.socket.on 'change_layer_properties', @changeLayerProperties

  getMap: =>
    matcher = /map=([a-zA-Z-0-9\_\-]+)/
    ref = @delegate.socket.handshake.headers.referer

    map = ref.match(matcher)?[1]

    if map
      try
        ObjectId map
      catch
        map

    else null

  userCanAccessMap: (cb) =>
    map = @getMap()

    params = if map instanceof ObjectId
      {_id: map}
    else
      # namespace by user
      {name: map, users: {$all: [@delegate.username]}}

    @maps.findOne params, (err, map) =>
      return cb "Error loading map", err if err
      return cb "No map found" unless map

      users = map.users
      unless users and (@delegate.username in users)
        return cb "You do not have permission to that map"
      else
        cb(null, map)

  getMaps: (data) =>
    async.waterfall [
      (cb) =>
        @maps.find({users: {$all: [@delegate.username]}}, {name: true}).toArray (err, results) =>
          return cb(err) if err


          cb(null, { maps: results })

    ], (err, result) =>
      return console.log err if err
      result.responseId = data.responseId if data.responseId?
      @delegate.socket.emit 'response', result

  newMap: (data) =>

    mapData = {}

    async.waterfall [
      (cb) =>
        return unless data.name and data.width and data.height

        mapData.users = [@delegate.username]
        mapData.name = data.name
        mapData.width = parseInt data.width
        mapData.height = parseInt data.height

        cb()

      (cb) =>
        @layers.insert {name: "layer-1"}, (err, layer) =>
          return cb "Error saving layer", err if err
          return cb "Layer failed to be created" unless layer?.ops?[0]

          id = layer.ops[0]._id
          mapData.layers = [id]

          cb()

      (cb) =>

        @maps.insert mapData, (err, map) =>
          return cb(err) if err
          return cb("Map failed to be created") unless map?.ops?[0]
          cb(null, map.ops[0])

    ], (err, result) =>
      return console.log err if err
      result.responseId = data.responseId if data.responseId?

      @delegate.socket.emit 'response', result

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
    name = data.name
    async.waterfall [
      @userCanAccessMap
      (map, cb) =>
        return cb "No name specified to create layer" unless name

        @layers.insert {name: name}, (err, layer) =>
          return cb "Error saving layer", err if err
          return cb "Layer failed to be created" unless layer?.ops?[0]

          id = layer.ops[0]._id
          cb(null, map, id)

      (map, layerId, cb) =>
          @maps.update {_id: map._id}, {$push: {layers: layerId}}, (err, result) =>
            return cb "Could not push new layer to map", err if err
            cb(null, layerId)

      (layerId, cb) =>
        @delegate.broadcastWithSender 'add_layer', {_id: layerId, name: name}
        cb()

    ], (err, result) =>
      return console.log err if err

  changeLayerProperties: (data) =>

    async.waterfall [
      @userCanAccessMap

      (map, cb) =>
        return cb("No id specified") unless (id = ObjectId(data.layerId))
        return cb("No properties specified") unless data.properties
        cb(null, id)

      (layerId, cb) =>
        @layers.update {_id: layerId}, {$set: {properties: data.properties}}, (err, layer) =>
          return cb(err) if err
          cb()

    ], (err, results) =>
      console.log(err) if err
      @delegate.broadcastWithSender 'change_layer_properties',
        layerId: data.layerId
        properties: data.properties

  renameLayer: (data) =>
    async.waterfall [
      @userCanAccessMap
      (map, cb) =>
        return cb("No id specified") unless (id = ObjectId(data.layerId))
        return cb("No name spcified") unless data.name

        cb(null, map, id)

      (map, layerId, cb) =>
        @layers.update {_id: layerId}, {$set: {name: data.name}}, (err, layer) =>
          return cb(err) if err
          cb()

    ], (err, result) =>
      return console.log err if err
      @delegate.broadcastWithSender 'rename_layer',
        layerId: data.layerId
        name: data.name

  deleteLayer: (data) =>
    async.waterfall [
      @userCanAccessMap
      (map, cb) =>
        return cb("No id specified") unless (id = ObjectId(data.layerId))

        cb(null, map, id)

      (map, layer, cb) =>
        @maps.update {_id: map._id}, {$pull: {layers: layer}}, (err, map) =>
          return cb(err) if err
          cb()

    ], (err, result) =>
      return console.log err if err
      @delegate.broadcastWithSender 'remove_layer', {layerId: data.layerId}

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
