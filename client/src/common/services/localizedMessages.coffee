angular.module("services.localizedMessages", []).factory "localizedMessages", ["$interpolate", "I18N.MESSAGES", ($interpolate, i18nmessages) ->
  handleNotFound = (msg, msgKey) ->
    msg or "?" + msgKey + "?"

  get: (msgKey, interpolateParams) ->
    msg = i18nmessages[msgKey]
    if msg
      $interpolate(msg) interpolateParams
    else
      handleNotFound msg, msgKey
]
