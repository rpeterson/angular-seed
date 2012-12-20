angular.module("directives.modal", []).directive "modal", ["$parse", ($parse) ->
  backdropEl = undefined
  body = angular.element(document.getElementsByTagName("body")[0])
  defaultOpts =
    backdrop: true
    escape: true

  restrict: "ECA"
  link: (scope, elm, attrs) ->
    setShown = (shown) ->
      scope.$apply ->
        model.assign scope, shown

    escapeClose = (evt) ->
      setClosed()  if evt.which is 27
    clickClose = ->
      setClosed()
    close = ->
      body.unbind "keyup", escapeClose  if opts.escape
      if opts.backdrop
        backdropEl.css("display", "none").removeClass "in"
        backdropEl.unbind "click", clickClose
      elm.css("display", "none").removeClass "in"
      body.removeClass "modal-open"
    open = ->
      body.bind "keyup", escapeClose  if opts.escape
      if opts.backdrop
        backdropEl.css("display", "block").addClass "in"
        backdropEl.bind "click", clickClose
      elm.css("display", "block").addClass "in"
      body.addClass "modal-open"
    opts = angular.extend(defaultOpts, scope.$eval(attrs.uiOptions or attrs.bsOptions or attrs.options))
    shownExpr = attrs.modal or attrs.show
    setClosed = undefined
    if attrs.close
      setClosed = ->
        scope.$apply attrs.close
    else
      setClosed = ->
        scope.$apply ->
          $parse(shownExpr).assign scope, false

    elm.addClass "modal"
    if opts.backdrop and not backdropEl
      backdropEl = angular.element("<div class=\"modal-backdrop\"></div>")
      backdropEl.css "display", "none"
      body.append backdropEl
    scope.$watch shownExpr, (isShown, oldShown) ->
      if isShown
        open()
      else
        close()

]
