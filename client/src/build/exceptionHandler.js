
angular.module("services.exceptionHandler", ["services.i18nNotifications"]);

angular.module("services.exceptionHandler").factory("exceptionHandlerFactory", [
  "$injector", function($injector) {
    return function($delegate) {
      return function(exception, cause) {
        var i18nNotifications;
        i18nNotifications = $injector.get("i18nNotifications");
        $delegate(exception, cause);
        return i18nNotifications.pushForCurrentRoute("error.fatal", "error", {}, {
          exception: exception,
          cause: cause
        });
      };
    };
  }
]);

angular.module("services.exceptionHandler").config([
  "$provide", function($provide) {
    return $provide.decorator("$exceptionHandler", [
      "$delegate", "exceptionHandlerFactory", function($delegate, exceptionHandlerFactory) {
        return exceptionHandlerFactory($delegate);
      }
    ]);
  }
]);
