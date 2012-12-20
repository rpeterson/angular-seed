
(function() {
  var crudRouteProvider;
  crudRouteProvider = function($routeProvider) {
    this.$get = function() {
      return {};
    };
    return this.routesFor = function(resourceName, urlPrefix, routePrefix) {
      var baseRoute, baseUrl, createRoute, routeBuilder;
      baseUrl = urlPrefix + "/" + resourceName.toLowerCase();
      routePrefix = routePrefix || urlPrefix;
      baseRoute = "/" + routePrefix + "/" + resourceName.toLowerCase();
      createRoute = function(operation, resolveFns) {
        return {
          templateUrl: baseUrl + "/" + resourceName.toLowerCase() + "-" + operation.toLowerCase() + ".tpl.html",
          controller: resourceName + operation + "Ctrl",
          resolve: resolveFns
        };
      };
      routeBuilder = {
        whenList: function(resolveFns) {
          routeBuilder.when(baseRoute, createRoute("List", resolveFns));
          return routeBuilder;
        },
        whenNew: function(resolveFns) {
          routeBuilder.when(baseRoute + "/new", createRoute("Edit", resolveFns));
          return routeBuilder;
        },
        whenEdit: function(resolveFns) {
          routeBuilder.when(baseRoute + "/:itemId", createRoute("Edit", resolveFns));
          return routeBuilder;
        },
        when: function(path, route) {
          $routeProvider.when(path, route);
          return routeBuilder;
        },
        otherwise: function(params) {
          $routeProvider.otherwise(params);
          return routeBuilder;
        },
        $routeProvider: $routeProvider
      };
      return routeBuilder;
    };
  };
  crudRouteProvider.$inject = ["$routeProvider"];
  return angular.module("services.crudRouteProvider", []).provider("crudRoute", crudRouteProvider);
})();
