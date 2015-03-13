Auth = require './app/auth'
App = require './app'
DB = require './db'

DB.init ->
  App.init()
  Auth.init()

