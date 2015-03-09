express = require 'express'
path = require 'path'
http = require 'http'
io = require 'socket.io'
fs = require 'fs'

app = express()

pub = path.join __dirname, '..', "/public"

app.use express.static(pub)

server = http.createServer app
io = io.listen server
server.listen 3000

io.on 'connection', (socket) ->
  socket.filename = ''

  socket.on 'load_map', (data) ->
    loadMap data, socket

  socket.on 'new_map', (data) ->
    newMap data, socket

  socket.on 'add_tile', (data) ->
    addTile data, socket

###########################################################################################
# loadMap(data, socket)
# data - {filename: NAME_OF_FILE}
# 
# This function loads the map with provided name
# 
loadMap = (data, socket) =>
  # leave user's current map room
  socket.leave socket.filename

  # bind current map name to socket (or future user class)
  socket.filename = data.filename

  # join new room for current map
  socket.join data.filename

  # check if filename passed in exists in our filesystem
  if not fs.existsSync path.join __dirname, '..', 'server/data/' + socket.filename
    # if it doesn't exist, ask client for map size
    # this will callback to our 'new_map' binding
    socket.emit 'get_new_map'
  else
    # map does exist, load into buffer
    map_buffer = fs.readFileSync path.join __dirname, '..','server/data/', data.filename

    # cast buffer to string, and then split by commad to generate our array
    map_array = map_buffer.toString().split ','

    # emit load map call to client with array being sent through socket
    socket.emit 'load_map', {map:map_array}
###########################################################################################

###########################################################################################
# newMap(data, socket)
# data - {x: MAP_SIZE.x, y: MAP_SIZE.y}
# 
# This function generates a new map with provided dimensions
# 
newMap = (data, socket) =>
  # after map size has been retrieved, build map of 0's in x by y dimensions
  map_array = []
  for i in [0...(data.y)]
    map_array[i] = []
    for j in [0...(data.x)]
      map_array[i][j] = '' 

  # write our map to filesystem file
  # this is currently done synchronously through a simply write
  # we likely don't need write streams for now as this is by far
  # efficient enough to work with
  fs.writeFileSync (path.join __dirname, '..','server/data/' + socket.filename), map_array.toString()

  loadMap {filename: socket.filename}, socket
###########################################################################################  

###########################################################################################
# addTile(data, socket)
# data - {x: x, y: y, layer: layer.index, index: index, map_x: MAP_SIZE.x, map_y: MAP_SIZE.y}
# 
# This function adds a tile to the work in progress map currently in use by user
# 
addTile = (data, socket) =>
  if fs.existsSync path.join __dirname, '..', 'server/data/' + socket.filename
    # read in our map file to buffer
    map_buffer = fs.readFileSync path.join __dirname, '..','server/data/' + socket.filename

    # cast buffer to string, and then split by commad to generate our array
    map_array = map_buffer.toString().split ','

    # assign tile type to the provided index
    # using 1-D array as 2-D using formula:
    #     (data.y*data.map_x) + data.x
    # this allows for easy CSV storage
    map_array[(data.y*data.map_x) + data.x] = data.index

    # write our array cast as string to file in our filesystem
    fs.writeFileSync (path.join __dirname, '..','server/data/' + socket.filename), map_array.toString()

    # emit to all user in room
    io.to(socket.filename).emit 'add_tile', data
###########################################################################################