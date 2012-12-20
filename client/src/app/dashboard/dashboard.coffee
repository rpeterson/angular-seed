namespace 'com.serenitysoft.controllers'

  DashboardCtrl:

    class DasboardCtrl

      @$inject: ["$scope", "$location"]

      constructor: (@$scope, @$location) ->
        @$scope.manageUsers = angular.bind this, @manageUsers

      manageUsers: ->
        @$location.path "/users"


angular.module( "dashboard", [])  #"services.authentication"
       .config(["$routeProvider", ($routeProvider) ->
          $routeProvider.when "/dashboard",
            templateUrl: "dashboard/dashboard.tpl.html"
            controller: "DashboardCtrl"
       ])
       .controller("DashboardCtrl", com.serenitysoft.controllers.DashboardCtrl)