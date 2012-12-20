angular.module "services.breadcrumbs", []
angular.module("services.breadcrumbs").factory "breadcrumbs", ["$rootScope", "$location", ($rootScope, $location) ->
  breadcrumbs = []
  breadcrumbsService = {}
  
  #we want to update breadcrumbs only when a route is actually changed
  #as $location.path() will get updated imediatelly (even if route change fails!)
  $rootScope.$on "$routeChangeSuccess", (event, current) ->
    pathElements = $location.path().split("/")
    result = []
    i = undefined
    breadcrumbPath = (index) ->
      "/" + (pathElements.slice(0, index + 1)).join("/")

    pathElements.shift()
    i = 0
    while i < pathElements.length
      result.push
        name: pathElements[i]
        path: breadcrumbPath(i)

      i++
    breadcrumbs = result

  breadcrumbsService.getAll = ->
    breadcrumbs

  breadcrumbsService.getFirst = ->
    breadcrumbs[0] or {}

  breadcrumbsService
]
