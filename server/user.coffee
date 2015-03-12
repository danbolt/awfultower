bcrypt = require 'bcrypt'
DB = require './db'

secret = "omgthisissosecretHAX"

class User
  constructor: ->

  init: ->
    @collection = DB.collection 'user'

  # Find a user given an unencrypted password and username
  findOne: (username, password, cb) ->
    @collection.findOne {username: username}, (err, user) =>
      return cb(err) if err
      return cb("Username not found") unless user
      bcrypt.compare password, user.password, (err, res) =>
        return cb(err) if err
        return cb("Invalid username or password") unless res
        cb(null, user)

  # Create a new user in the DB if the coast is clear
  create: (username, password, cb) ->
    @collection.findOne {username: username}, (err, user) =>
      return cb(err) if err
      return cb("Username already taken") if user

      # Generate the password
      bcrypt.genSalt 10, (err, salt) =>
        return cb(err) if err
        bcrypt.hash password, salt, (err, hash) =>
          return cb(err) if err
          @collection.insert {username: username, password: hash}, null, (err, user) =>
            return cb(err) if err
            return cb(null, user)

  # Generate a token when the user logs in
  login: (username, password, cb) ->
    @findOne username, password, (err, user) =>
      return cb(err) if err
      @generateToken user, cb

  # Create the token after the user logs in
  generateToken: (user, cb) ->
    string = "#{user.username}#{secret}#{user.password}"
    bcrypt.genSalt 10, (err, salt) =>
      return cb(err) if err
      bcrypt.hash string, salt, (err, hash) =>
        return cb(err) if err
        # Include the username so that we know which user to we are trying to
        # auth in the future
        token = "#{user.username}--::--#{hash}"
        cb(null, token)

  # Given a session token, does it match the user's generated session token?
  compareToken: (token, cb) ->

    [username,token] = token.split("--::--")
    @collection.findOne {username: username}, (err, user) =>
      return cb(err) if err
      return cb("User not found") unless user

      string = "#{user.username}#{secret}#{user.password}"

      # Figure out what the encoded token should be
      bcrypt.genSalt 10, (err, salt) =>
        return cb(err) if err
        bcrypt.hash string, salt, (err, hash) =>
          return cb(err) if err
          # If they match, the session token was good
          bcrypt.compare string, token, (err, res) =>
            return cb(err) if err
            return cb("Invalid token") unless res

            cb(null)

module.exports = new User()
