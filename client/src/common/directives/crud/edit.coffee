
# Apply this directive to an element at or below a form that will manage CRUD operations on a resource.
# - The resource must expose the following instance methods: $saveOrUpdate(), $id() and $remove()
angular.module("directives.crud.edit", []).directive "crudEdit", ["$parse", ($parse) ->
  
  # We ask this directive to create a new child scope so that when we add helper methods to the scope
  # it doesn't make a mess of the parent scope.
  # - Be aware that if you write to the scope from within the form then you must remember that there is a child scope at the point
  scope: true
  
  # We need access to a form so we require a FormController from this element or a parent element
  require: "^form"
  
  # This directive can only appear as an attribute
  link: (scope, element, attrs, form) ->
    
    # We extract the value of the crudEdit attribute
    # - it should be an assignable expression evaluating to the model (resource) that is going to be edited
    resourceGetter = $parse(attrs.crudEdit)
    resourceSetter = resourceGetter.assign
    
    # Store the resource object for easy access
    resource = resourceGetter(scope)
    
    # Store a copy for reverting the changes
    original = angular.copy(resource)
    checkResourceMethod = (methodName) ->
      throw new Error("crudEdit directive: The resource must expose the " + methodName + "() instance method")  unless angular.isFunction(resource[methodName])

    checkResourceMethod "$saveOrUpdate"
    checkResourceMethod "$id"
    checkResourceMethod "$remove"
    
    # This function helps us extract the callback functions from the directive attributes
    makeFn = (attrName) ->
      fn = scope.$eval(attrs[attrName])
      throw new Error("crudEdit directive: The attribute \"" + attrName + "\" must evaluate to a function")  unless angular.isFunction(fn)
      fn

    
    # Set up callbacks with fallback
    # onSave attribute -> onSave scope -> noop
    onSave = (if attrs.onSave then makeFn("onSave") else (scope.onSave or angular.noop))
    
    # onRemove attribute -> onRemove scope -> onSave attribute -> onSave scope -> noop
    onRemove = (if attrs.onRemove then makeFn("onRemove") else (scope.onRemove or onSave))
    
    # onError attribute -> onError scope -> noop
    onError = (if attrs.onError then makeFn("onError") else (scope.onError or angular.noop))
    
    # The following functions should be triggered by elements on the form
    # - e.g. ng-click="save()"
    scope.save = ->
      resource.$saveOrUpdate onSave, onSave, onError, onError

    scope.revertChanges = ->
      resource = angular.copy(original)
      resourceSetter scope, resource

    scope.remove = ->
      if resource.$id()
        resource.$remove onRemove, onError
      else
        onRemove()

    
    # The following functions can be called to modify the behaviour of elements in the form
    # - e.g. ng-disable="!canSave()"
    scope.canSave = ->
      form.$valid and not angular.equals(resource, original)

    scope.canRevert = ->
      not angular.equals(resource, original)

    scope.canRemove = ->
      resource.$id()

    
    ###
    Get the CSS classes for this item, to be used by the ng-class directive
    @param {string} fieldName The name of the field on the form, for which we want to get the CSS classes
    @return {object} A hash where each key is a CSS class and the corresponding value is true if the class is to be applied.
    ###
    scope.getCssClasses = (fieldName) ->
      ngModelContoller = form[fieldName]
      error: ngModelContoller.$invalid and not angular.equals(resource, original)
      success: ngModelContoller.$valid and not angular.equals(resource, original)

    
    ###
    Whether to show an error message for the specified error
    @param {string} fieldName The name of the field on the form, of which we want to know whether to show the error
    @param  {string} error - The name of the error as given by a validation directive
    @return {Boolean} true if the error should be shown
    ###
    scope.showError = (fieldName, error) ->
      form[fieldName].$error[error]
]
