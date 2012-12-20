angular.module "services.authentication.interceptor", ["services.authentication.retry-queue"]

# This http interceptor listens for authentication failures
angular.module("services.authentication.interceptor").factory "AuthenticationInterceptor", ["$rootScope", "$injector", "$q", "AuthenticationRetryQueue", ($rootScope, $injector, $q, queue) ->
  $http = undefined # To be lazy initialized to prevent circular dependency
  (promise) ->
    $http = $http or $injector.get("$http")
    
    # Intercept failed requests
    promise.then null, (originalResponse) ->
      if originalResponse.status is 401
        
        # The request bounced because it was not authorized - add a new request to the retry queue
        promise = queue.pushPromiseFn(->
          $http originalResponse.config
        , "unauthorized-server")
      promise

]

# We have to add the interceptor to the queue as a string because the interceptor depends upon service instances that are not available in the config block.
angular.module("services.authentication.interceptor").config ["$httpProvider", ($httpProvider) ->
  $httpProvider.responseInterceptors.push "AuthenticationInterceptor"
]
