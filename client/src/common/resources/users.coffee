angular.module "resources.users", ["mongolabResource"]
angular.module("resources.users").factory "Users", ["mongolabResource", (mongoResource) ->
  userResource = mongoResource("users")
  userResource::getFullName = ->
    @lastName + " " + @firstName + " (" + @email + ")"

  userResource
]
