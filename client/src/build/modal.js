
angular.module("directives.modal", []).directive("modal", [
  "$parse", function($parse) {
    var backdropEl, body, defaultOpts;
    backdropEl = void 0;
    body = angular.element(document.getElementsByTagName("body")[0]);
    defaultOpts = {
      backdrop: true,
      escape: true
    };
    return {
      restrict: "ECA",
      link: function(scope, elm, attrs) {
        var clickClose, close, escapeClose, open, opts, setClosed, setShown, shownExpr;
        setShown = function(shown) {
          return scope.$apply(function() {
            return model.assign(scope, shown);
          });
        };
        escapeClose = function(evt) {
          if (evt.which === 27) {
            return setClosed();
          }
        };
        clickClose = function() {
          return setClosed();
        };
        close = function() {
          if (opts.escape) {
            body.unbind("keyup", escapeClose);
          }
          if (opts.backdrop) {
            backdropEl.css("display", "none").removeClass("in");
            backdropEl.unbind("click", clickClose);
          }
          elm.css("display", "none").removeClass("in");
          return body.removeClass("modal-open");
        };
        open = function() {
          if (opts.escape) {
            body.bind("keyup", escapeClose);
          }
          if (opts.backdrop) {
            backdropEl.css("display", "block").addClass("in");
            backdropEl.bind("click", clickClose);
          }
          elm.css("display", "block").addClass("in");
          return body.addClass("modal-open");
        };
        opts = angular.extend(defaultOpts, scope.$eval(attrs.uiOptions || attrs.bsOptions || attrs.options));
        shownExpr = attrs.modal || attrs.show;
        setClosed = void 0;
        if (attrs.close) {
          setClosed = function() {
            return scope.$apply(attrs.close);
          };
        } else {
          setClosed = function() {
            return scope.$apply(function() {
              return $parse(shownExpr).assign(scope, false);
            });
          };
        }
        elm.addClass("modal");
        if (opts.backdrop && !backdropEl) {
          backdropEl = angular.element("<div class=\"modal-backdrop\"></div>");
          backdropEl.css("display", "none");
          body.append(backdropEl);
        }
        return scope.$watch(shownExpr, function(isShown, oldShown) {
          if (isShown) {
            return open();
          } else {
            return close();
          }
        });
      }
    };
  }
]);
