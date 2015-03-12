express = require 'express'
path = require 'path'

User = require '../user'

pub = path.join __dirname, '../..', "/public"
staticFiles = express.static(pub)

router = express.Router()

# Eventually we will probably want to get the user, if there is a token
router.get '/', (req, res, next) ->
  next()

# Try to get the login page, or redirect to / if they have a valid session token
router.get '/login', (req, res, next) ->
  if req.session.usertoken
    User.compareToken req.session.usertoken, (err) ->
      if not err then res.redirect '/'
      else res.sendFile "#{pub}/login.html"
  else res.sendFile "#{pub}/login.html"

# Try to log the user in
router.post '/login', (req, res, next) ->
  User.login req.body.username, req.body.password, (err, token) ->
    if err
      res.redirect '/login'
    else
      # Save the usertoken in the session
      req.session.usertoken = token
      res.redirect '/'

router.get '/logout', (req, res, next) ->
  req.session.destroy()
  res.redirect '/'


module.exports = [router, staticFiles]
