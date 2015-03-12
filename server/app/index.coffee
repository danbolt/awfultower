express = require 'express'
path = require 'path'
http = require 'http'
session = require 'express-session'
cookieParser = require 'cookie-parser'
bodyParser = require 'body-parser'

MongoStore = require('connect-mongo')(session)
SocketManager = require '../socket_manager'
DB = require '../db'
router = require './router'

class App
  constructor: ->

  init: ->

    app = express()
    app.use bodyParser.urlencoded(extended: false)
    app.use cookieParser()
    app.use session
      secret: "Put a secret here.."
      resave: true
      saveUninitialized: true
      store: new MongoStore(db: DB.db)

    app.use router

    server = http.createServer app
    server.listen 3000

    SocketManager.init server

module.exports = new App()
