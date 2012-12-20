
angular.module("services.authentication", ["services.authentication.current-user", "services.authentication.interceptor", "services.authentication.retry-queue"]);

angular.module("services.authentication").factory("AuthenticationService", [
  "$http", "$location", "$q", "AuthenticationRetryQueue", "currentUser", function($http, $location, $q, queue, currentUser) {
    var redirect, service, updateCurrentUser;
    redirect = function(url) {
      url = url || "/";
      return $location.path(url);
    };
    updateCurrentUser = function(user) {
      currentUser.update(user);
      if (!!user) {
        return queue.retry();
      }
    };
    service = {
      isLoginRequired: function() {
        return queue.hasMore();
      },
      getLoginReason: function() {
        return queue.getReason();
      },
      showLogin: function() {
        return queue.push({
          retry: function() {},
          cancel: function() {},
          reason: "user-request"
        });
      },
      login: function(email, password) {
        var request;
        request = $http.post("/login", {
          email: email,
          password: password
        });
        return request.then(function(response) {
          updateCurrentUser(response.data.user);
          return currentUser.isAuthenticated();
        });
      },
      cancelLogin: function(redirectTo) {
        queue.cancel();
        return redirect(redirectTo);
      },
      logout: function(redirectTo) {
        return $http.post("/logout").then(function() {
          currentUser.clear();
          return redirect(redirectTo);
        });
      },
      requestCurrentUser: function() {
        if (currentUser.isAuthenticated()) {
          return $q.when(currentUser);
        } else {
          return $http.get("/current-user").then(function(response) {
            updateCurrentUser(response.data.user);
            return currentUser;
          });
        }
      },
      requireAuthenticatedUser: function() {
        var promise;
        promise = service.requestCurrentUser().then(function(currentUser) {
          if (!currentUser.isAuthenticated()) {
            return queue.pushPromiseFn(service.requireAuthenticatedUser, "unauthenticated-client");
          }
        });
        return promise;
      },
      requireAdminUser: function() {
        var promise;
        promise = service.requestCurrentUser().then(function(currentUser) {
          if (!currentUser.isAdmin()) {
            return queue.pushPromiseFn(service.requireAdminUser, "unauthorized-client");
          }
        });
        return promise;
      }
    };
    service.requestCurrentUser();
    return service;
  }
]);
