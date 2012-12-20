
angular.module("services.authentication.retry-queue", []);

angular.module("services.authentication.retry-queue").factory("AuthenticationRetryQueue", [
  "$q", function($q) {
    var retryQueue, service;
    retryQueue = [];
    service = {
      push: function(retryItem) {
        return retryQueue.push(retryItem);
      },
      pushPromiseFn: function(promiseFn, reason) {
        var deferred, retryItem;
        deferred = $q.defer();
        retryItem = {
          reason: reason,
          retry: function() {
            return promiseFn().then(function(value) {
              return deferred.resolve(value);
            });
          },
          cancel: function() {
            return deferred.reject();
          }
        };
        service.push(retryItem);
        return deferred.promise;
      },
      hasMore: function() {
        return retryQueue.length > 0;
      },
      getReason: function() {
        if (service.hasMore()) {
          return retryQueue[0].reason;
        }
      },
      getNext: function() {
        return retryQueue.shift();
      },
      cancel: function() {
        var _results;
        _results = [];
        while (service.hasMore()) {
          _results.push(service.getNext().cancel());
        }
        return _results;
      },
      retry: function() {
        var _results;
        _results = [];
        while (service.hasMore()) {
          _results.push(service.getNext().retry());
        }
        return _results;
      }
    };
    return service;
  }
]);
