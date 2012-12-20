angular.module "services.authentication.current-user", []

# The current user.  You can watch this for changes due to logging in and out
angular.module("services.authentication.current-user").factory "currentUser", ->
  userInfo = null
  currentUser =
    update: (info) ->
      userInfo = info

    clear: ->
      userInfo = null

    info: ->
      userInfo

    isAuthenticated: ->
      !!userInfo

    isAdmin: ->
      !!(userInfo and userInfo.admin)

  currentUser

