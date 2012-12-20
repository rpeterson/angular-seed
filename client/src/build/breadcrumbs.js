
angular.module("services.breadcrumbs", []);

angular.module("services.breadcrumbs").factory("breadcrumbs", [
  "$rootScope", "$location", function($rootScope, $location) {
    var breadcrumbs, breadcrumbsService;
    breadcrumbs = [];
    breadcrumbsService = {};
    $rootScope.$on("$routeChangeSuccess", function(event, current) {
      var breadcrumbPath, i, pathElements, result;
      pathElements = $location.path().split("/");
      result = [];
      i = void 0;
      breadcrumbPath = function(index) {
        return "/" + (pathElements.slice(0, index + 1)).join("/");
      };
      pathElements.shift();
      i = 0;
      while (i < pathElements.length) {
        result.push({
          name: pathElements[i],
          path: breadcrumbPath(i)
        });
        i++;
      }
      return breadcrumbs = result;
    });
    breadcrumbsService.getAll = function() {
      return breadcrumbs;
    };
    breadcrumbsService.getFirst = function() {
      return breadcrumbs[0] || {};
    };
    return breadcrumbsService;
  }
]);
