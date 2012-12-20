# Based loosely around work by Witold Szczerba - https://github.com/witoldsz/angular-http-auth
angular.module "services.authentication", ["services.authentication.current-user", "services.authentication.interceptor", "services.authentication.retry-queue"]

# The AuthenticationService is the public API for this module.  Application developers should only need to use this service and not any of the others here.
angular.module("services.authentication").factory "AuthenticationService", ["$http", "$location", "$q", "AuthenticationRetryQueue", "currentUser", ($http, $location, $q, queue, currentUser) ->

  # TODO: We need a way to refresh the page to clear any data that has been loaded when the user logs out
  #  a simple way would be to redirect to the root of the application but this feels a bit inflexible.
  redirect = (url) ->
    url = url or "/"
    $location.path url
  updateCurrentUser = (user) ->
    currentUser.update user
    queue.retry()  unless not user
  service =
    isLoginRequired: ->
      queue.hasMore()

    getLoginReason: ->
      queue.getReason()

    showLogin: ->

      # Push a no-op onto the queue to create a manual login
      queue.push
        retry: ->

        cancel: ->

        reason: "user-request"


    login: (email, password) ->
      request = $http.post("/login",
        email: email
        password: password
      )
      request.then (response) ->
        updateCurrentUser response.data.user
        currentUser.isAuthenticated()


    cancelLogin: (redirectTo) ->
      queue.cancel()
      redirect redirectTo

    logout: (redirectTo) ->
      $http.post("/logout").then ->
        currentUser.clear()
        redirect redirectTo



    # Ask the backend to see if a users is already authenticated - this may be from a previous session.
    # The app should probably do this at start up
    requestCurrentUser: ->
      if currentUser.isAuthenticated()
        $q.when currentUser
      else
        $http.get("/current-user").then (response) ->
          updateCurrentUser response.data.user
          currentUser


    requireAuthenticatedUser: ->
      promise = service.requestCurrentUser().then((currentUser) ->
        queue.pushPromiseFn service.requireAuthenticatedUser, "unauthenticated-client"  unless currentUser.isAuthenticated()
      )
      promise

    requireAdminUser: ->
      promise = service.requestCurrentUser().then((currentUser) ->
        queue.pushPromiseFn service.requireAdminUser, "unauthorized-client"  unless currentUser.isAdmin()
      )
      promise


  # Get the current user when the service is instantiated
  service.requestCurrentUser()
  service
]