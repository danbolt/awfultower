_ = require 'underscore'
multer = require 'multer'
uuid = require 'node-uuid'
path = require 'path'

db = require '../db'
Auth = require './auth'

ObjectId = require('mongodb').ObjectID

class FileUpload
  init: (@app) =>

    imageUploadMulter = multer
      dest: './uploads'
      rename: (fieldname, filename) ->
        console.log "field", fieldname, "file", filename
        uuid.v4()

      onFileUploadStart: (file) ->

      onFileUploadComplete: (file) ->
        console.log file

    @app.post '/tilesheet', imageUploadMulter, (req, res) ->

      return res.send "Must be logged in" unless (token = req.session.usertoken)
      return res.send "No tilesheet" unless (tilesheet = req.files?.tilesheet)?

      Auth.getUsernameFromToken token, (err, username) ->
        return console.log err if err

        tileData =
          originalName: tilesheet.originalname
          name: tilesheet.name

        db.collection('tilesheet').insert tileData, (err, ts) ->
          return res.send err if err
          return res.send "Couldnt inser tilesheet" unless (id = ts?.ops[0]?._id)
          db.collection('user').update {username: username}, {$push: {tilesheets: id}}, (err, result) =>
            return res.send err if err
            return res.end "success"

    @app.get '/tilesheet/:id', (req, res) ->

      return res.send "Must be logged in" unless (token = req.session.usertoken)

      Auth.getUsernameFromToken token, (err, username) ->
        return console.log err if err
        db.collection('user').findOne {username: username}, (err, user) ->
          return unless user

          tilesheet = _.last user.tilesheets

          db.collection('tilesheet').findOne {_id: ObjectId(tilesheet)}, (err, ts) ->
            return if err or not ts
            filepath = path.resolve('uploads/', ts.name)

            res.sendFile filepath

module.exports = new FileUpload
