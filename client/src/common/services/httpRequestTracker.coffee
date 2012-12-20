angular.module "services.httpRequestTracker", []
angular.module("services.httpRequestTracker").factory "httpRequestTracker", ["$http", ($http) ->
  httpRequestTracker = {}
  httpRequestTracker.hasPendingRequests = ->
    $http.pendingRequests.length > 0

  httpRequestTracker
]