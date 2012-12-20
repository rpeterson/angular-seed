angular.module "services.crud", ["services.crudRouteProvider"]
angular.module("services.crud").factory "crudEditMethods", ->
  (itemName, item, formName, successcb, errorcb) ->
    mixin = {}
    mixin[itemName] = item
    mixin[itemName + "Copy"] = angular.copy(item)
    mixin.save = ->
      this[itemName].$saveOrUpdate successcb, successcb, errorcb, errorcb

    mixin.canSave = ->
      this[formName].$valid and not angular.equals(this[itemName], this[itemName + "Copy"])

    mixin.revertChanges = ->
      this[itemName] = angular.copy(this[itemName + "Copy"])

    mixin.canRevert = ->
      not angular.equals(this[itemName], this[itemName + "Copy"])

    mixin.remove = ->
      if this[itemName].$id()
        this[itemName].$remove successcb, errorcb
      else
        successcb()

    mixin.canRemove = ->
      item.$id()

    
    ###
    Get the CSS classes for this item, to be used by the ng-class directive
    @param {string} fieldName The name of the field on the form, for which we want to get the CSS classes
    @return {object} A hash where each key is a CSS class and the corresponding value is true if the class is to be applied.
    ###
    mixin.getCssClasses = (fieldName) ->
      ngModelContoller = this[formName][fieldName]
      error: ngModelContoller.$invalid and ngModelContoller.$dirty
      success: ngModelContoller.$valid and ngModelContoller.$dirty

    
    ###
    Whether to show an error message for the specified error
    @param {string} fieldName The name of the field on the form, of which we want to know whether to show the error
    @param  {string} error - The name of the error as given by a validation directive
    @return {Boolean} true if the error should be shown
    ###
    mixin.showError = (fieldName, error) ->
      this[formName][fieldName].$error[error]

    mixin

angular.module("services.crud").factory "crudListMethods", ["$location", ($location) ->
  (pathPrefix) ->
    mixin = {}
    mixin["new"] = ->
      $location.path pathPrefix + "/new"

    mixin["edit"] = (itemId) ->
      $location.path pathPrefix + "/" + itemId

    mixin
]
