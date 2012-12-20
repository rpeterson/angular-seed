describe "hello world scenario", ->
  scope = undefined
  $controller = undefined
  beforeEach module("app")
  beforeEach inject((_$rootScope_, _$controller_) ->
    scope = _$rootScope_.$new()
    $controller = _$controller_
  )
