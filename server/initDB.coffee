config = require("./config.coffee").mongo
rest = require("restler")
baseUrl = config.dbUrl + "/" + config.dbName + "/collections/"
queryOptions = apiKey: config.apiKey

console.log "Configuration: \n", config

checkDocument = (collection, query, done) ->
  url = baseUrl + collection + "/"
  params =
    apiKey: config.apiKey
    q: JSON.stringify(query)

  request = rest.get(url,
    query: params
  )
  request.on "error", (err, response) ->
    done err, null

  request.on "fail", (err, response) ->
    done err, null

  request.on "success", (data) ->
    done null, data


createDocument = (collection, document, done) ->
  url = baseUrl + collection + "/?apiKey=" + config.apiKey
  request = rest.postJson(url, document)
  request.on "error", (err, response) ->
    done err, null

  request.on "fail", (err, response) ->
    done err, null

  request.on "success", (data) ->
    done null, data


console.log "Generating admin user..."
adminUser =
  email: "admin@example.com"
  password: "changeme"
  admin: true

checkDocument config.usersCollection, adminUser, (err, data) ->
  if not err and data.length is 0
    createDocument config.usersCollection, adminUser, (err, data) ->
      console.log err
      console.log data

  else
    console.log "User already created."
