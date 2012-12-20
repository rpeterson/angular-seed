angular.module "services.exceptionHandler", ["services.i18nNotifications"]
angular.module("services.exceptionHandler").factory "exceptionHandlerFactory", ["$injector", ($injector) ->
  ($delegate) ->
    (exception, cause) ->
      
      # Lazy load notifications to get around circular dependency
      #Circular dependency: $rootScope <- notifications <- i18nNotifications <- $exceptionHandler
      i18nNotifications = $injector.get("i18nNotifications")
      
      # Pass through to original handler
      $delegate exception, cause
      
      # Push a notification error
      i18nNotifications.pushForCurrentRoute "error.fatal", "error", {},
        exception: exception
        cause: cause

]
angular.module("services.exceptionHandler").config ["$provide", ($provide) ->
  $provide.decorator "$exceptionHandler", ["$delegate", "exceptionHandlerFactory", ($delegate, exceptionHandlerFactory) ->
    exceptionHandlerFactory $delegate
  ]
]
