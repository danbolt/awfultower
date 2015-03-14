express = require 'express'
path = require 'path'

Auth = require './auth'

pub = path.join __dirname, '../..', "/public"
staticFiles = express.static(pub)

router = express.Router()

# Eventually we will probably want to get the user, if there is a token
router.get '/', (req, res, next) ->
  next()

# Try to get the login page, or redirect to / if they have a valid session token
router.get '/login', (req, res, next) ->
  if req.session.usertoken
    Auth.compareToken req.session.usertoken, (err) ->
      if not err then res.redirect '/'
      else res.sendFile "#{pub}/login.html"
  else res.sendFile "#{pub}/login.html"

# Try to log the user in
router.post '/login', (req, res, next) ->
  Auth.login req.body.username, req.body.password, (err, token) ->
    if err
      res.redirect '/login'
    else
      # Save the usertoken in the session
      req.session.usertoken = token
      res.redirect '/'

router.get '/logout', (req, res, next) ->
  req.session.destroy()
  res.redirect '/'

router.post '/signup', (req, res, next) ->
  Auth.create req.body.username, req.body.password, (err, user) ->

    return res.redirect '/login' if err
    Auth.login req.body.username, req.body.password, (err, token) ->
      if err
        res.redirect '/login'
      else
        # Save the usertoken in the session
        req.session.usertoken = token
        res.redirect '/'

router.get '/user', (req, res, next) ->
  res.send username: null unless (token = req.session.usertoken)
  Auth.getUsernameFromToken token, (err, username) ->
    return console.log err if err

    res.send username: username


module.exports = [router, staticFiles]
