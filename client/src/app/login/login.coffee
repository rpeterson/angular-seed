angular.module("login", ["services.authentication", "services.localizedMessages", "directives.modal"]).directive "loginForm", ["AuthenticationService", "localizedMessages", "currentUser", (AuthenticationService, localizedMessages, currentUser) ->
  directive =
    templateUrl: "login/form.tpl.html"
    restrict: "E"
    scope: true
    link: ($scope, $element, $attrs, $controller) ->
      $scope.user = {}
      $scope.authError = null
      $scope.authService = AuthenticationService
      $scope.showLoginForm = false
      $scope.clearForm = ->
        $scope.user = {}

      $scope.showLogin = (msg) ->
        $scope.authError = msg
        $scope.showLoginForm = true

      $scope.cancelLogin = ->
        AuthenticationService.cancelLogin()

      $scope.hideLogin = ->
        $scope.showLoginForm = false

      $scope.getLoginReason = ->
        reason = AuthenticationService.getLoginReason()
        isAuthenticated = currentUser.isAuthenticated()
        message = ""
        switch reason
          when "user-request"
            message = "Please enter you login details below"
          when "unauthenticated-client", "unauthorized-client"
          , "unauthorized-server"
            if isAuthenticated
              message = localizedMessages.get("login.error.notAuthorized")
            else
              message = localizedMessages.get("login.error.notAuthenticated")
          else
            message = ""
        message


      # A login is required.  If the user decides not to login then we can call cancel
      $scope.$watch AuthenticationService.isLoginRequired, (value) ->
        if value
          $scope.showLogin $scope.getLoginReason()
        else
          $scope.hideLogin()

      $scope.login = ->
        $scope.authError = null
        AuthenticationService.login($scope.user.email, $scope.user.password).then (loggedIn) ->
          $scope.authError = "Login failed.  Please check your credentials and try again."  unless loggedIn


  directive
]
angular.module("login").directive "loginToolbar", ["currentUser", "AuthenticationService", (currentUser, AuthenticationService) ->
  directive =
    templateUrl: "login/toolbar.tpl.html"
    restrict: "E"
    replace: true
    scope: true
    link: ($scope, $element, $attrs, $controller) ->
      $scope.userInfo = currentUser.info
      $scope.isAuthenticated = currentUser.isAuthenticated
      $scope.logout = ->
        AuthenticationService.logout()

      $scope.login = ->
        AuthenticationService.showLogin()

  directive
]