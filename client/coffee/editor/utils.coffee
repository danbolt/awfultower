LevelData = require './lib/level_data'

tileWidth = LevelData.tileWidth
tileHeight = LevelData.tileHeight

module.exports =
  tileWidth: tileWidth
  tileHeight: tileHeight

  sign: (n) ->
    if n is 0 then 0
    else if n > 0 then 1
    else -1
