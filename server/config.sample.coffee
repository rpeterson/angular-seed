path = require("path")
module.exports =
  mongo:
    dbUrl: "https://api.mongolab.com/api/1/databases" # The base url of the MongoLab DB server
    apiKey: "" # Our MongoLab API key
    dbName: "angular-seed" # The name of database to which this server connect
    usersCollection: "users" # The name of the collection that will contain our user information

  server:
    listenPort: 3000 # The port on which the server is to listen (means that the app is at http://localhost:3000 for instance)
    distFolder: path.resolve(__dirname, "../client/dist") # The folder that contains the application files (note that the files are in a different repository) - relative to this file
    staticUrl: "/static" # The base url from which we serve static files (such as js, css and images)
    cookieSecret: "angular-seed" # The secret for encrypting the cookie