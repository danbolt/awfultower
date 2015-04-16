express = require 'express'
path = require 'path'
http = require 'http'
session = require 'express-session'
cookieParser = require 'cookie-parser'
bodyParser = require 'body-parser'
config = require 'config'

MongoStore = require('connect-mongo')(session)
SocketManager = require './sockets'
DB = require '../db'
router = require './router'
FileUpload = require './file_upload'

class App
  constructor: ->

  init: ->
    sessionMiddleware = session
      secret: config.sessionSecret
      resave: true
      saveUninitialized: true
      store: new MongoStore(db: DB.db)

    app = express()
    app.use bodyParser.urlencoded(extended: false)
    app.use cookieParser()
    app.use sessionMiddleware

    app.use router

    FileUpload.init app

    server = http.createServer app
    server.listen 3000

    SocketManager.init server, sessionMiddleware

module.exports = new App()
