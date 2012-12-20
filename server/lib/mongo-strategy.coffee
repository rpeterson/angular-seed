
MongoDBStrategy = (dbUrl, apiKey, dbName, collection) ->
  @dbUrl = dbUrl
  @apiKey = apiKey
  @dbName = dbName
  @collection = collection
  @baseUrl = @dbUrl + "/" + @dbName + "/collections/" + collection + "/"

  # We want this strategy to have a nice name for use by passport, e.g. app.post('/login', passport.authenticate('mongo'));
  @name = "mongo"

  # Call the super constructor - passing in our user verification function
  # We use the email field for the username
  LocalStrategy.call this,
    usernameField: "email"
  , @verifyUser.bind(this)

  # Serialize the user into a string (id) for storing in the session
  passport.serializeUser (user, done) ->
    done null, user._id.$oid # Remember that MongoDB has this weird { _id: { $oid: 1234567 } } structure


  # Deserialize the user from a string (id) into a user (via a cll to the DB)
  passport.deserializeUser @get.bind(this)

util = require("util")
passport = require("passport")
LocalStrategy = require("passport-local").Strategy
rest = require("restler")

# MongoDBStrategy inherits from LocalStrategy
util.inherits MongoDBStrategy, LocalStrategy


# Query the users collection
MongoDBStrategy::query = (query, done) ->
  query.apiKey = @apiKey # Add the apiKey to the passed in query
  request = rest.get(@baseUrl,
    query: query
  )
  request.on "error", (err, response) ->
    done err, null

  request.on "fail", (err, response) ->
    done err, null

  request.on "success", (data) ->
    done null, data



# Get a user by id
MongoDBStrategy::get = (id, done) ->
  request = rest.get(@baseUrl + id,
    query:
      apiKey: @apiKey
  )
  request.on "error", (err, response) ->
    done err, null

  request.on "fail", (err, response) ->
    done err, null

  request.on "success", (data) ->
    done null, data



# Find a user by their email
MongoDBStrategy::findByEmail = (email, done) ->
  @query
    q: JSON.stringify(email: email)
  , (err, result) ->
    return done(err, result[0])  if result and result.length is 1
    done err, null



# Check whether the user passed in is a valid one
MongoDBStrategy::verifyUser = (email, password, done) ->
  @findByEmail email, (err, user) ->
    user = null  if user.password isnt password  if not err and user
    done err, user


module.exports = MongoDBStrategy

# TODO: Store hashes rather than passwords... node-bcrypt requires python to be installed :-(
#var bcrypt = require('bcrypt');
#function hashPassword(password) {
#  return bcrypt.hashSync(password, bcrypt.genSaltSync());
#}
#
#function checkPassword(password, hash) {
#  return bcrypt.compareSync(password, hash);
#}
#