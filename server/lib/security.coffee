express = require("express")
passport = require("passport")
MongoStrategy = require("./mongo-strategy")
app = express()
filterUser = (user) ->
  if user
    user:
      id: user._id.$oid
      email: user.email
      firstName: user.firstName
      lastName: user.lastName
      admin: user.admin
  else
    user: null

security =
  initialize: (url, apiKey, dbName, authCollection) ->
    passport.use new MongoStrategy(url, apiKey, dbName, authCollection)

  authenticationRequired: (req, res, next) ->
    if req.isAuthenticated()
      next()
    else
      res.send 401, filterUser(req.user)

  adminRequired: (req, res, next) ->
    if req.user and req.user.admin
      next()
    else
      res.send 401, filterUser(req.user)

  sendCurrentUser: (req, res, next) ->
    res.json 200, filterUser(req.user)
    res.end()

  login: (req, res, next) ->
    authenticationFailed = (err, user, info) ->
      return next(err)  if err
      return res.json(filterUser(user))  unless user
      req.logIn user, (err) ->
        return next(err)  if err
        res.json filterUser(user)

    passport.authenticate(MongoStrategy.name, authenticationFailed) req, res, next

  logout: (req, res, next) ->
    req.logout()
    res.send 204

module.exports = security