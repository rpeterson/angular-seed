angular.module "services.authentication.retry-queue", []

# This is a generic retry queue for authentication failures.  Each item is expected to expose two functions: retry and cancel.
angular.module("services.authentication.retry-queue").factory "AuthenticationRetryQueue", ["$q", ($q) ->
  retryQueue = []
  service =
    push: (retryItem) ->
      retryQueue.push retryItem

    pushPromiseFn: (promiseFn, reason) ->
      deferred = $q.defer()
      retryItem =
        reason: reason
        retry: ->
          promiseFn().then (value) ->
            deferred.resolve value


        cancel: ->
          deferred.reject()

      service.push retryItem
      deferred.promise

    hasMore: ->
      retryQueue.length > 0

    getReason: ->
      retryQueue[0].reason  if service.hasMore()

    getNext: ->
      retryQueue.shift()

    cancel: ->
      service.getNext().cancel()  while service.hasMore()

    retry: ->
      service.getNext().retry()  while service.hasMore()

  service
]
