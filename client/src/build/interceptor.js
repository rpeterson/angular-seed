
angular.module("services.authentication.interceptor", ["services.authentication.retry-queue"]);

angular.module("services.authentication.interceptor").factory("AuthenticationInterceptor", [
  "$rootScope", "$injector", "$q", "AuthenticationRetryQueue", function($rootScope, $injector, $q, queue) {
    var $http;
    $http = void 0;
    return function(promise) {
      $http = $http || $injector.get("$http");
      return promise.then(null, function(originalResponse) {
        if (originalResponse.status === 401) {
          promise = queue.pushPromiseFn(function() {
            return $http(originalResponse.config);
          }, "unauthorized-server");
        }
        return promise;
      });
    };
  }
]);

angular.module("services.authentication.interceptor").config([
  "$httpProvider", function($httpProvider) {
    return $httpProvider.responseInterceptors.push("AuthenticationInterceptor");
  }
]);
