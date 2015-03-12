User = require './user'
App = require './app'
DB = require './db'

DB.init ->
  App.init()
  User.init()

