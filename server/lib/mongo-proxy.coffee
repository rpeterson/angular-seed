url = require("url")
qs = require("querystring")
https = require("https")
module.exports = (basePath, apiKey) ->
  console.log "Proxying MongoLab at", basePath, "with", apiKey
  basePath = url.parse(basePath)

  # Map the request url to the mongolab url
  # @Returns a parsed Url object
  mapUrl = module.exports.mapUrl = (reqUrlString) ->
    reqUrl = url.parse(reqUrlString, true)
    newUrl =
      hostname: basePath.hostname
      protocol: basePath.protocol

    query = apiKey: apiKey
    for key of reqUrl.query
      query[key] = reqUrl.query[key]

    # https request expects path not pathname!
    newUrl.path = basePath.pathname + reqUrl.pathname + "?" + qs.stringify(query)
    newUrl


  # Map the incoming request to a request to the DB
  mapRequest = module.exports.mapRequest = (req) ->
    newReq = mapUrl(req.url)
    newReq.method = req.method
    newReq.headers = req.headers or {}

    # We need to fix up the hostname
    newReq.headers.host = newReq.hostname
    newReq

  proxy = (req, res, next) ->
    try
      options = mapRequest(req)

      # Create the request to the db
      dbReq = https.request(options, (dbRes) ->
        data = ""
        res.headers = dbRes.headers
        dbRes.setEncoding "utf8"
        dbRes.on "data", (chunk) ->

          # Pass back any data from the response.
          data = data + chunk

        dbRes.on "end", ->
          res.statusCode = dbRes.statusCode
          res.httpVersion = dbRes.httpVersion
          res.trailers = dbRes.trailers
          res.send data
          res.end()

      )

      # Send any data the is passed from the original request
      dbReq.end JSON.stringify(req.body)
    catch error
      console.log "ERROR: ", error.stack
      res.json error
      res.end()


  # Attach the mapurl fn (mostly for testing)
  proxy.mapUrl = mapUrl
  proxy.mapRequest = mapRequest
  proxy