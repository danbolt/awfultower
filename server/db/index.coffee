MongoClient = require('mongodb').MongoClient
config = require 'config'


class DB
  constructor: ->

  init: (cb) ->
    url = config.get 'server.db'

    MongoClient.connect url, (err, db) =>
      return cb(err) if err
      @db = db
      cb()

  close: =>
    @db.close()

  collection: (col) =>
    @db.collection col

module.exports = new DB()
