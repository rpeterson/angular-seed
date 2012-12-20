(->
  crudRouteProvider = ($routeProvider) ->
    @$get = -> #we are not interested in instances
      {}

    @routesFor = (resourceName, urlPrefix, routePrefix) ->
      baseUrl = urlPrefix + "/" + resourceName.toLowerCase()
      routePrefix = routePrefix or urlPrefix
      baseRoute = "/" + routePrefix + "/" + resourceName.toLowerCase()
      createRoute = (operation, resolveFns) ->
        templateUrl: baseUrl + "/" + resourceName.toLowerCase() + "-" + operation.toLowerCase() + ".tpl.html"
        controller: resourceName + operation + "Ctrl"
        resolve: resolveFns

      routeBuilder =
        whenList: (resolveFns) ->
          routeBuilder.when baseRoute, createRoute("List", resolveFns)
          routeBuilder

        whenNew: (resolveFns) ->
          routeBuilder.when baseRoute + "/new", createRoute("Edit", resolveFns)
          routeBuilder

        whenEdit: (resolveFns) ->
          routeBuilder.when baseRoute + "/:itemId", createRoute("Edit", resolveFns)
          routeBuilder

        when: (path, route) ->
          $routeProvider.when path, route
          routeBuilder

        otherwise: (params) ->
          $routeProvider.otherwise params
          routeBuilder

        $routeProvider: $routeProvider

      routeBuilder
  
  # Add our injection dependencies here since we cannot do it in module.provider()
  crudRouteProvider.$inject = ["$routeProvider"]
  angular.module("services.crudRouteProvider", []).provider "crudRoute", crudRouteProvider
)()
