_ = require 'underscore'
fs = require 'fs'
path = require 'path'
async = require 'async'

DB = require '../../../db'

ObjectId = require('mongodb').ObjectID

module.exports = class Tilemap
  constructor: (@delegate) ->
    @tilesheets = DB.collection 'tilesheet'

    @delegate.socket.on 'new_tilesheet', @newTilesheet

  newTilesheet: (data) =>
    console.log data

