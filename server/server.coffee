express = require("express")
mongoProxy = require("./lib/mongo-proxy")
config = require("./config.coffee")
passport = require("passport")
security = require("./lib/security")
app = express()

# Serve up the favicon
app.use express.favicon(config.server.distFolder + "/favicon.ico")

# First looks for a static file: index.html, css, images, etc.
app.use config.server.staticUrl, express["static"](config.server.distFolder)
app.use config.server.staticUrl, (req, res, next) ->
  res.send 404 # If we get here then the request for a static file is invalid

app.use express.logger() # Log requests to the console
app.use express.bodyParser() # Extract the data from the body of the request - this is needed by the LocalStrategy authenticate method
app.use express.cookieParser(config.server.cookieSecret) # Hash cookies with this secret
app.use express.cookieSession() # Store the session in the (secret) cookie
app.use passport.initialize() # Initialize PassportJS
app.use passport.session() # Use Passport's session authentication strategy - this stores the logged in user in the session and will now run on any request
security.initialize config.mongo.dbUrl, config.mongo.apiKey, config.mongo.dbName, config.mongo.usersCollection # Add a Mongo strategy for handling the authentication

app.use (req, res, next) ->
  if req.user
    console.log "Current User:", req.user.firstName, req.user.lastName
  else
    console.log "Unauthenticated"
  next()

app.use "/databases", (req, res, next) ->
  if req.method isnt "GET"

    # We require the user is authenticated to modify any collections
    security.authenticationRequired req, res, next
  else
    next()

app.use "/databases/angular-seed/collections/users", (req, res, next) ->
  if req.method isnt "GET"

    # We require the current user to be admin to modify the users collection
    security.adminRequired req, res, next
  else
    next()

app.use "/databases/angular-seed/collections/projects", (req, res, next) ->
  if req.method isnt "GET"

    # We require the current user to be admin to modify the projects collection
    security.adminRequired req, res, next
  else
    next()


# Proxy database calls to the MongoDB
app.use "/databases", mongoProxy(config.mongo.dbUrl, config.mongo.apiKey)
app.post "/login", security.login
app.post "/logout", security.logout

# Retrieve the current user
app.get "/current-user", security.sendCurrentUser

# Retrieve the current user only if they are authenticated
app.get "/authenticated-user", (req, res) ->
  security.authenticationRequired req, res, ->
    security.sendCurrentUser req, res



# Retrieve the current user only if they are admin
app.get "/admin-user", (req, res) ->
  security.adminRequired req, res, ->
    security.sendCurrentUser req, res



# This route deals enables HTML5Mode by forwarding missing files to the index.html
app.all "/*", (req, res) ->

  # Just send the index.html for other files to support HTML5Mode
  res.sendfile "index.html",
    root: config.server.distFolder



# A standard error handler - it picks up any left over errors and returns a nicely formatted http 500 error
app.use express.errorHandler(
  dumpExceptions: true
  showStack: true
)

# Start up the server on the port specified in the config
app.listen config.server.listenPort
console.log "Angular App Server - listening on port: " + config.server.listenPort