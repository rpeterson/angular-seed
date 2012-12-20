
angular.module("services.authentication.current-user", []);

angular.module("services.authentication.current-user").factory("currentUser", function() {
  var currentUser, userInfo;
  userInfo = null;
  currentUser = {
    update: function(info) {
      return userInfo = info;
    },
    clear: function() {
      return userInfo = null;
    },
    info: function() {
      return userInfo;
    },
    isAuthenticated: function() {
      return !!userInfo;
    },
    isAdmin: function() {
      return !!(userInfo && userInfo.admin);
    }
  };
  return currentUser;
});
