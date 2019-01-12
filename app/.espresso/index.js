// Generated by CoffeeScript 1.6.3
/*
  Module dependencies.
*/

var app, config, express, io, path, routes, server, serverStarted;

config = require("./config");

express = require("express");

path = require("path");

routes = require("./routes");

app = express();

/*
  Configuration
*/


app.configure("development", "testing", "production", function() {
  return config.setEnv(app.settings.env);
});

app.set("ipaddr", config.HOSTNAME);

app.set("port", config.PORT);

app.set("views", path.join(process.cwd(), config.VIEWS_PATH));

app.set("view engine", config.VIEWS_ENGINE);

app.use(express.bodyParser());

app.use(express.methodOverride());

app.use(app.router);

app.use(express.favicon("" + (process.cwd()) + "/" + config.PUBLIC_PATH + "/" + config.IMAGES_PATH + "/favicon.ico"));

app.use(express["static"](path.join(process.cwd(), config.PUBLIC_PATH)));

app.get("/", routes.index);

app.all("/log", routes.log);

serverStarted = function() {
  return console.log("Server listening on http://" + (app.get("ipaddr")) + ":" + (app.get("port")));
};

server = app.listen(app.get('port'), app.get('ipaddr'), serverStarted);

io = require("socket.io").listen(server);

require("./socket").configure(io);

module.exports = server;