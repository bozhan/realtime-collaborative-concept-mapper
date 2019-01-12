sId = undefined
exports.configure = (io) ->

  #Socket.IO config
  io.on "connection", (socket) ->
    console.log "New socket connected!"
    fs = require 'fs'
    moment = require 'moment'
    socketUser = undefined
    logFileName = undefined

    logEvent = (user, event) ->
      if logFileName != undefined && socketUser != undefined
        timeStamp = moment().format("YYYYMMDD,HHmmss")
        msg = "\n" + timeStamp + "," + socketUser + "," + event
        fs.appendFile logFileName, msg, (err) ->
          if (err)
            console.log err

    saveToFile = (data) ->
#      conceptMap = JSON.parse(data)
#      meta = conceptMap.meta
#      filename = "./#{config.DATA_PATH}/cm_" + meta.target.id + '_' + meta.target.user + '.json' # for future use to save use specific concepts
      filename = "./data/cm.json"
      fs.writeFile filename , JSON.stringify(data), (err) ->
        if (err)
          console.log err
        console.log 'saved to server:' + filename

    socket.on "sessionId", (data) ->
      console.log "sId:" + sId
      if sId == undefined
        sId = data
        socket.emit "sessionId", sId
      else
        socket.emit "sessionId", sId
      console.log "sId:" + sId

    socket.on "login", (data) ->
      io.sockets.emit "login", data.user
      socketUser = data.user
      logFileName = "./log/" + socketUser + ".txt"
#      console.log "in login called"
      logEvent socketUser, "logged in"

    socket.on "saveConcept", (data) ->
      console.log "response to saveConcept call!"
      saveToFile JSON.parse(data)

    socket.on "loadConcept", ->
#      loadFs = require 'fs'
      filename = "./data/cm.json"
      fs.readFile filename, 'utf8', (err, data) ->
        if (err)
          console.log 'Error: ' + err
        data = JSON.parse(data);
        console.log 'got file ' + filename
        io.sockets.emit "sendConcept", data

    socket.on "createConcept", (concept) ->
      socket.broadcast.emit "createConcept", JSON.parse(concept)
#      console.log "Socket answer to createConcept!"
      logEvent socketUser, "create concept " + JSON.parse(concept).id

    socket.on "deleteConcept", (id) ->
      socket.broadcast.emit "deleteConcept", id
#      console.log "Socket answer to deleteConcept!"
      logEvent socketUser, "delete concept " + id

    socket.on "deleteAll", ->
      socket.broadcast.emit "deleteAll"
      logEvent socketUser, "delete all"

    socket.on "deleteRelation", (data) ->
#      console.log "Socket answer to deleteRelation!"
      data = JSON.parse(data)
      socket.broadcast.emit "deleteRelation", data
      logEvent socketUser, "delete relation b/w " + data.source + " and " + data.target

    socket.on "startMoveConcept", (id) ->
#      console.log "Socket answer to startMoveConept!"
      socket.broadcast.emit "lockConcept", id

    socket.on "dragConcept", (data) ->
      socket.broadcast.emit "moveConcept", JSON.parse(data)

    socket.on "stoptMoveConcept", (data) ->
#      console.log "Socket answer to stoptMoveConcept!"
      socket.broadcast.emit "moveConcept", JSON.parse(data)

    socket.on "createRelation", (data) ->
#      console.log "Create Relation b/w " + data.source + " and " + data.target
      socket.broadcast.emit "createRelation", JSON.parse(data)

    socket.on "updateConceptContent", (data) ->
#      console.log "Update content of " + data.id
      socket.broadcast.emit "updateConceptContent", JSON.parse(data)

    socket.on "updateRelationLabel", (data) ->
#      console.log "Update relation label of " + data.id
      socket.broadcast.emit "updateRelationLabel", JSON.parse(data)

    socket.on "disconnect", (data) ->
      console.log "user disconnected"
#      saveToFile JSON.parse(data)