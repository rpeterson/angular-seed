var DasboardCtrl;

namespace('com.serenitysoft.controllers', {
  DashboardCtrl: DasboardCtrl = (function() {

    DasboardCtrl.$inject = ["$scope", "$location"];

    function DasboardCtrl($scope, $location) {
      this.$scope = $scope;
      this.$location = $location;
      this.$scope.manageUsers = angular.bind(this, this.manageUsers);
    }

    DasboardCtrl.prototype.manageUsers = function() {
      return this.$location.path("/users");
    };

    return DasboardCtrl;

  })()
});

angular.module("dashboard", []).config([
  "$routeProvider", function($routeProvider) {
    return $routeProvider.when("/dashboard", {
      templateUrl: "dashboard/dashboard.tpl.html",
      controller: "DashboardCtrl"
    });
  }
]).controller("DashboardCtrl", com.serenitysoft.controllers.DashboardCtrl);
