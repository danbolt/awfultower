express = require 'express'
path = require 'path'
http = require 'http'
SocketManager = require './socket_manager'

app = express()

pub = path.join __dirname, '..', "/public"

app.use express.static(pub)

server = http.createServer app
server.listen 3000

SocketManager.init server
