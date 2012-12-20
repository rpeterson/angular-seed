
angular.module("directives.crud.edit", []).directive("crudEdit", [
  "$parse", function($parse) {
    return {
      scope: true,
      require: "^form",
      link: function(scope, element, attrs, form) {
        var checkResourceMethod, makeFn, onError, onRemove, onSave, original, resource, resourceGetter, resourceSetter;
        resourceGetter = $parse(attrs.crudEdit);
        resourceSetter = resourceGetter.assign;
        resource = resourceGetter(scope);
        original = angular.copy(resource);
        checkResourceMethod = function(methodName) {
          if (!angular.isFunction(resource[methodName])) {
            throw new Error("crudEdit directive: The resource must expose the " + methodName + "() instance method");
          }
        };
        checkResourceMethod("$saveOrUpdate");
        checkResourceMethod("$id");
        checkResourceMethod("$remove");
        makeFn = function(attrName) {
          var fn;
          fn = scope.$eval(attrs[attrName]);
          if (!angular.isFunction(fn)) {
            throw new Error("crudEdit directive: The attribute \"" + attrName + "\" must evaluate to a function");
          }
          return fn;
        };
        onSave = (attrs.onSave ? makeFn("onSave") : scope.onSave || angular.noop);
        onRemove = (attrs.onRemove ? makeFn("onRemove") : scope.onRemove || onSave);
        onError = (attrs.onError ? makeFn("onError") : scope.onError || angular.noop);
        scope.save = function() {
          return resource.$saveOrUpdate(onSave, onSave, onError, onError);
        };
        scope.revertChanges = function() {
          resource = angular.copy(original);
          return resourceSetter(scope, resource);
        };
        scope.remove = function() {
          if (resource.$id()) {
            return resource.$remove(onRemove, onError);
          } else {
            return onRemove();
          }
        };
        scope.canSave = function() {
          return form.$valid && !angular.equals(resource, original);
        };
        scope.canRevert = function() {
          return !angular.equals(resource, original);
        };
        scope.canRemove = function() {
          return resource.$id();
        };
        /*
            Get the CSS classes for this item, to be used by the ng-class directive
            @param {string} fieldName The name of the field on the form, for which we want to get the CSS classes
            @return {object} A hash where each key is a CSS class and the corresponding value is true if the class is to be applied.
        */

        scope.getCssClasses = function(fieldName) {
          var ngModelContoller;
          ngModelContoller = form[fieldName];
          return {
            error: ngModelContoller.$invalid && !angular.equals(resource, original),
            success: ngModelContoller.$valid && !angular.equals(resource, original)
          };
        };
        /*
            Whether to show an error message for the specified error
            @param {string} fieldName The name of the field on the form, of which we want to know whether to show the error
            @param  {string} error - The name of the error as given by a validation directive
            @return {Boolean} true if the error should be shown
        */

        return scope.showError = function(fieldName, error) {
          return form[fieldName].$error[error];
        };
      }
    };
  }
]);
