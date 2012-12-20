describe "admin users", ->

  $scope = undefined
  $controller = undefined
  params = undefined
  ctrl = undefined

  beforeEach module("admin-users")

  describe "controllers", ->
    beforeEach inject(($injector) ->
      $scope = $injector.get("$rootScope")
      $controller = $injector.get("$controller")
    )
    describe "UsersListCtrl", ->
      it "should call crudListMethods", ->
        params =
          $scope: $scope
          crudListMethods: jasmine.createSpy("crudListMethods")
          users: {}

        ctrl = $controller("UsersListCtrl", params)
        expect($scope.users).toBe params.users
        expect(params.crudListMethods).toHaveBeenCalled()

    describe "UsersEditCtrl", ->

      beforeEach ->
        params =
          $scope: $scope
          $location: jasmine.createSpyObj("$location", ["path"])
          i18nNotifications: jasmine.createSpyObj("i18nNotifications", ["pushForCurrentRoute", "pushForNextRoute"])
          user: jasmine.createSpyObj("user", ["$id"])

        params.user.password = "XXX"
        ctrl = $controller("UsersEditCtrl", params)

      it "should set up the scope correctly", ->
        expect($scope.password).toBe $scope.user.password

      it "should call $location in onSave", ->
        $scope.onSave $id: angular.noop
        expect(params.i18nNotifications.pushForNextRoute).toHaveBeenCalled()
        expect(params.$location.path).toHaveBeenCalled()

      it "should set updateError in onError", ->
        $scope.onError()
        expect(params.i18nNotifications.pushForCurrentRoute).toHaveBeenCalled()



  describe "validateEquals directive", ->
    setTestValue = (value) ->
      $scope.model.testValue = value
      $scope.$digest()
    setCompareTo = (value) ->
      $scope.model.compareTo = value
      $scope.$digest()
    $scope = undefined
    form = undefined
    beforeEach inject(($compile, $rootScope) ->
      $scope = $rootScope
      element = angular.element("<form name=\"form\"><input name=\"testInput\" ng-model=\"model.testValue\" validate-equals=\"model.compareTo\"></form>")
      $scope.model =
        testValue: ""
        compareTo: ""

      $compile(element) $scope
      $scope.$digest()
      form = $scope.form
    )
    describe "model validity", ->
      it "should be valid initially", ->
        expect(form.testInput.$valid).toBe true

      it "should be invalid if the model changes", ->
        setTestValue "different"
        expect(form.testInput.$valid).toBe false

      it "should be invalid if the reference model changes", ->
        setCompareTo "different"
        expect(form.testInput.$valid).toBe false

      it "should be valid if the model changes to be the same as the reference", ->
        setCompareTo "different"
        expect(form.testInput.$valid).toBe false
        setTestValue "different"
        expect(form.testInput.$valid).toBe true



  describe "uniqueEmail directive", ->
    setTestValue = (value) ->
      $scope.model.testValue = value
      $scope.$digest()
    Users = undefined
    $scope = undefined
    form = undefined

    # Mockup Users resource
    angular.module("test", []).factory "Users", ->
      Users = jasmine.createSpyObj("Users", ["query"])
      Users

    beforeEach module("test")
    beforeEach inject(($compile, $rootScope) ->
      $scope = $rootScope
      element = angular.element("<form name=\"form\"><input name=\"testInput\" ng-model=\"model.testValue\" unique-email></form>")
      $scope.model = testValue: null
      $compile(element) $scope
      $scope.$digest()
      form = $scope.form
    )
    it "should be valid initially", ->
      expect(form.testInput.$valid).toBe true

    it "should not call Users.query when the model changes", ->
      setTestValue "different"
      expect(Users.query).not.toHaveBeenCalled()

    it "should call Users.query when the view changes", ->
      form.testInput.$setViewValue "different"
      expect(Users.query).toHaveBeenCalled()

    it "should set model to invalid if the Users callback contains users", ->
      Users.query.andCallFake (query, callback) ->
        callback ["someUser"]

      form.testInput.$setViewValue "different"
      expect(form.testInput.$valid).toBe false

    it "should set model to valid if the Users callback contains no users", ->
      Users.query.andCallFake (query, callback) ->
        callback []

      form.testInput.$setViewValue "different"
      expect(form.testInput.$valid).toBe true


