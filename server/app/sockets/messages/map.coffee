_ = require 'underscore'
fs = require 'fs'
path = require 'path'
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

  loadMap: (data) =>
    name = data.map

    @maps.findOne {name: name}, (err, map) =>
      return console.log "Error loading map", err if err
      return console.log "No map found with name: #{name}" unless map

      data = {width: map.width, height: map.height, name: map.name}

      @delegate.joinRoom name
      @currentMap = map

      if map.layers
        @layers.find({_id: {$in: map.layers}}).toArray (err, layers) =>
          return console.log "Error loading layers", err if err
          data.layers = layers
          @delegate.socket.emit 'load_map', data

          if data.layers?.length
            @currentLayer = layers[0]

      else
        @delegate.socket.emit 'load_map', data

  addLayer: (data) =>
    name = data.name
    console.log "new layer! #{name}"

    return console.log "No name specified to create layer" unless name
    @layers.insert {name: name}, (err, layer) =>
      return console.log "Error saving layer", err if err
      return console.log "Layer failed to be created" unless layer?.ops?[0]

      id = layer.ops[0]._id

      @maps.update {_id: @currentMap._id}, {$push: {layers: id}}, (err, result) =>
        return console.log "Could not push new layer to map", err if err

  # Batch up changes, clear the interval whenever anything changes. After 2000
  # seconds (of inactivity), write the changes
  addTile: (data) =>
    @delegate.broadcast 'add_tile', data

    return console.log "No id specified" unless (id = ObjectId(data.layerId))

    property = "data.#{data.x}.#{data.y}"

    obj = {}
    obj[property] = data.index

    @layers.update {_id: id}, {$set: obj}

  # Remove the tile in the database
  removeTile: (data) =>
    @delegate.broadcast 'remove_tile', data

    return console.log "No id specified" unless (id = ObjectId(data.layerId))

    property = "data.#{data.x}.#{data.y}"

    obj = {}
    obj[property] = ""

    @layers.update {_id: id}, {$unset: obj}

