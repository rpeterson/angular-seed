angular.module "app", ["login","dashboard", "admin", "services.breadcrumbs", "services.i18nNotifications", "services.httpRequestTracker", "templates"] # "directives.crud",

angular.module("app").constant "MONGOLAB_CONFIG",
  baseUrl: "http://localhost:3000/databases/"
  dbName: "angular-seed"


#TODO: move those messages to a separate module
angular.module("app").constant "I18N.MESSAGES",
  "errors.route.changeError": "Route change error"
  "crud.user.save.success": "A user with id '{{id}}' was saved successfully."
  "crud.user.remove.success": "A user with id '{{id}}' was removed successfully."
  "crud.user.save.error": "Something went wrong when saving a user..."
  "login.error.notAuthorized": "You do not have the necessary access permissions.  Do you want to login as someone else?"
  "login.error.notAuthenticated": "You must be logged in to access this part of the application."

angular.module("app").config ["$routeProvider", "$locationProvider", ($routeProvider, $locationProvider) ->
  $locationProvider.html5Mode true
  $routeProvider.otherwise redirectTo: "/"
]
angular.module("app").controller "AppCtrl", ["$scope", "i18nNotifications", "localizedMessages", ($scope, i18nNotifications) ->
  $scope.notifications = i18nNotifications
  $scope.removeNotification = (notification) ->
    i18nNotifications.remove notification

  $scope.$on "$routeChangeError", (event, current, previous, rejection) ->
    i18nNotifications.pushForCurrentRoute "errors.route.changeError", "error", {},
      rejection: rejection
]

angular.module("app").controller "HeaderCtrl", ["$scope", "$location", "$route", "currentUser", "breadcrumbs", "notifications", "httpRequestTracker", ($scope, $location, $route, currentUser, breadcrumbs, notifications, httpRequestTracker) ->
  $scope.location = $location
  $scope.currentUser = currentUser
  $scope.breadcrumbs = breadcrumbs
  $scope.home = ->
    if $scope.currentUser.isAuthenticated()
      $location.path "/dashboard"
    else
      $location.path "/"

  $scope.isNavbarActive = (navBarPath) ->
    navBarPath is breadcrumbs.getFirst().name

  $scope.hasPendingRequests = ->
    httpRequestTracker.hasPendingRequests()
]