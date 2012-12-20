
angular.module("login", ["services.authentication", "services.localizedMessages", "directives.modal"]).directive("loginForm", [
  "AuthenticationService", "localizedMessages", "currentUser", function(AuthenticationService, localizedMessages, currentUser) {
    var directive;
    directive = {
      templateUrl: "login/form.tpl.html",
      restrict: "E",
      scope: true,
      link: function($scope, $element, $attrs, $controller) {
        $scope.user = {};
        $scope.authError = null;
        $scope.authService = AuthenticationService;
        $scope.showLoginForm = false;
        $scope.clearForm = function() {
          return $scope.user = {};
        };
        $scope.showLogin = function(msg) {
          $scope.authError = msg;
          return $scope.showLoginForm = true;
        };
        $scope.cancelLogin = function() {
          return AuthenticationService.cancelLogin();
        };
        $scope.hideLogin = function() {
          return $scope.showLoginForm = false;
        };
        $scope.getLoginReason = function() {
          var isAuthenticated, message, reason;
          reason = AuthenticationService.getLoginReason();
          isAuthenticated = currentUser.isAuthenticated();
          message = "";
          switch (reason) {
            case "user-request":
              message = "Please enter you login details below";
              break;
            case "unauthenticated-client":
            case "unauthorized-client":
            case "unauthorized-server":
              if (isAuthenticated) {
                message = localizedMessages.get("login.error.notAuthorized");
              } else {
                message = localizedMessages.get("login.error.notAuthenticated");
              }
              break;
            default:
              message = "";
          }
          return message;
        };
        $scope.$watch(AuthenticationService.isLoginRequired, function(value) {
          if (value) {
            return $scope.showLogin($scope.getLoginReason());
          } else {
            return $scope.hideLogin();
          }
        });
        return $scope.login = function() {
          $scope.authError = null;
          return AuthenticationService.login($scope.user.email, $scope.user.password).then(function(loggedIn) {
            if (!loggedIn) {
              return $scope.authError = "Login failed.  Please check your credentials and try again.";
            }
          });
        };
      }
    };
    return directive;
  }
]);

angular.module("login").directive("loginToolbar", [
  "currentUser", "AuthenticationService", function(currentUser, AuthenticationService) {
    var directive;
    directive = {
      templateUrl: "login/toolbar.tpl.html",
      restrict: "E",
      replace: true,
      scope: true,
      link: function($scope, $element, $attrs, $controller) {
        $scope.userInfo = currentUser.info;
        $scope.isAuthenticated = currentUser.isAuthenticated;
        $scope.logout = function() {
          return AuthenticationService.logout();
        };
        return $scope.login = function() {
          return AuthenticationService.showLogin();
        };
      }
    };
    return directive;
  }
]);
