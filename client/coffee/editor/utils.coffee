LevelData = require './lib/level_data'

tileWidth = LevelData.tileWidth
tileHeight = LevelData.tileHeight

module.exports =
  tileWidth: tileWidth
  tileHeight: tileHeight

  # Is a number negative or positive
  sign: (n) ->
    if n is 0 then 0
    else if n > 0 then 1
    else -1

  getParameterByName: (name) ->
    name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]")
    regex = new RegExp("[\\?&]" + name + "=([^&#]*)")
    results = regex.exec location.search
    if results is null
      ""
    else
      decodeURIComponent results[1].replace(/\+/g, " ")

