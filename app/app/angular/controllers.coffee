"use strict"

SocketCtrl = ($scope, Socket) ->

  Socket.on "login", (user) ->
    console.log "Logging started for " + user

  Socket.on 'sendConcept', (data) ->
    console.log "Loading concept " + $scope.ctrl.meta.target.objectType
    $scope.ctrl.setConceptMapFromJSON(data)

  Socket.on 'createConcept', (concept) ->
    $scope.ctrl.createConcept(concept.id, concept.content, concept.x, concept.y, concept.type)

  Socket.on 'deleteConcept', (id) ->
    $.each $("#ut_tools_conceptmapper_map .ut_tools_conceptmapper_concept"), (index, concept) =>
      if id == $(concept).attr("id")
        $scope.ctrl.removeConcept(concept)

  Socket.on 'deleteAll', ->
    $scope.ctrl.deleteAll()

  Socket.on 'lockConcept', (id) ->
#    $scope.ctrl.lockConept(id)
    console.log 'Locking concept: ' + id
    jsPlumb.repaintEverything()

  Socket.on 'moveConcept', (data) ->
#    console.log 'Moving concept: ' + data.id
    if $scope.ctrl.conceptExists(data.id)
      $scope.ctrl.moveConcept(data.id, data.x, data.y)
    else
      console.log "No concept found with id:" + data.id

  Socket.on 'createRelation', (data) ->
#    if $scope.ctrl.connectionExists(data.source, data.target)
#      $scope.ctrl.deleteConnectionsBetween(data.source, data.target)
#    else
    console.log "Create Relation b/w " + data.source + " and " + data.target
    jsPlumb.connect(data)
    jsPlumb.repaintEverything()

  Socket.on 'deleteRelation', (data) ->
    console.log "Create Relation b/w " + data.source + " and " + data.target
    $scope.ctrl.deleteConnectionsBetween(data.source, data.target)

  Socket.on 'updateConceptContent', (data) ->
    console.log 'Update content of: ' + data.id + " with: " + data.content
    $scope.ctrl.updateConceptContent(data.id, data.content)

  Socket.on 'updateRelationLabel', (data) ->
    console.log 'Update relation label of: ' + data.id + " with: " + data.content
    $scope.ctrl.updateRelationLabel(data.id, data.content)

  Socket.on 'sessionId', (data) ->
    console.log "sessionID:" + data
    $scope.ctrl.actionLogger.setProvider {objectType: "dummy ILS", id: data}

SocketCtrl.$inject = ["$scope", "Socket"]

class BaseCtrl
  constructor: (Socket) ->
    console.log("All your base are belong to us!")
    window.ut = window.ut || {}
    window.ut.tools = window.ut.tools|| {}
    window.ut.tools.conceptmapper = window.ut.tools.conceptmapper || {}
    window.sessionId = ut.commons.utils.generateUUID();
    window.notificationClient = new ude.commons.NotificationClient(window.sessionId);

  toJson: (item) ->
    JSON.stringify(item)

#------------------------------------------------------------------------------------------------------------------------------------

class window.ut.tools.conceptmapper.ConceptMapper extends BaseCtrl
  #FIXME delete long nodes
  #constructor: (@$scope, configurationUrl) ->

  constructor: (@$scope, Socket) ->
    super
#    console.log(@$scope)
    @conceptTitle = 'Concept Map'
    @socket = Socket
    window.mySocket = @socket #expose socket to window for jsPlumb API to detect movement of concepts
    $(window).unload () ->
      @socket.emit "disconnect"
    console.log("Initializing ConceptMapper.")
    #  the metadata corresponds to the according sections in ActivityStream logging
    @meta = {
      "target": {
        "objectType": "conceptMap",
        "id": ut.commons.utils.generateUUID(),
        "displayName": "unnamed concept map",
        "user": "defaultUser"
      },
      "generator": {
        "objectType": "application",
        "url": document.URL,
        "id": ut.commons.utils.generateUUID(),
        "displayName": "ut.tools.conceptmapper"
      }
    }
    #-
    # keeps track of the current mode
    @LINK_MODE = "link_mode"
    @NODE_MODE = "node_mode"
    @mode = @NODE_MODE
    # flag to turn on/off logging, e.g. for loading
    @isCurrentlyLogging = true
    @sourceNode = undefined
    @targetNode = undefined
    @editingLabel = undefined
    @storage = undefined
    #-
    @actionLogger = new ut.commons.actionlogging.ActionLogger()
    @configuration = window.ut.tools.conceptmapper.defaultConfiguration
    @configure(window.ut.tools.conceptmapper.defaultConfiguration)
    @_init()
    # TODO what's the verb, here?
    @_logAction("application_started", {})
#    @socket.emit "loadConcept"

  login: () ->
    @meta.target.user  = @$scope.user
    console.log "Logged in as " + @meta.target.user
    @actionLogger.setTarget(@meta.target)
    #TODO
#    @actionLogger.actorId = @meta.target.user
    @socket.emit("login", {"user":@meta.target.user})

  getUser: () ->
    return @meta.target.user

  configure: (newConfiguration) =>
    $.each newConfiguration, (id, settings) =>
      # overwrite @configuration with new settings
      @configuration[""+id].value = settings.value
      # for the following settings special actions are neccessary
      switch id
        when "actionlogging"
          @actionLogger.setLoggingTargetByName(settings.value)
          @actionLogger.setTarget(@meta.target)
          @actionLogger.setGenerator(@meta.generator)
          @socket.emit("sessionId", window.sessionId)
#          if window.sessionId isnt undefined
#            @actionLogger.setProvider {objectType: "dummy ILS", id: window.sessionId}
        when "relations"
        # jsPlumb needs to be initialized again to have the correct default relation label
          @_initJsPlumb()
        when "textarea_concepts"
          $("#ut_tools_conceptmapper_toolbar_list").find(".ut_tools_conceptmapper_conceptTextarea").each (id, template) ->
            if settings.value is "false"
              $(template).hide()
            else
              $(template).show()
        when "combobox_concepts"
          $("#ut_tools_conceptmapper_toolbar_list").find(".ut_tools_conceptmapper_conceptSelector").each (id, template) ->
            if settings.value is "false"
              $(template).hide()
            else
              $(template).show()

  consumeNotification: (notification) =>
    if @configuration.debug.value is "true"
      console.log "ConceptMapper.consumeNotification: received notification: "
      console.log notification
    if notification.type is "prompt" and @configuration["show_prompts"].value is "true"
      $("#ut_tools_conceptmapper_dialog").text(notification.content.text)
      $("#ut_tools_conceptmapper_dialog").dialog {
        title: "Notification",
        resizable: false,
        modal: true,
        autoOpen: false,
        height: 150,
        closeOnEscape: false,
        dialogClass: "ut_tools_conceptmapper_dialog",
        buttons: {
          "Ok": () =>
            $("#ut_tools_conceptmapper_dialog").dialog("close")
        }
      }
      # open dialog now and remove focus from buttons
      $('#ut_tools_conceptmapper_dialog').dialog('open')
      $('.ui-dialog :button').blur()
    else if notification.type is "configuration"
      @configure(notification.content.configuration)
    else
      console.log "ConceptMapper: Notification wasn't a 'prompt' or prompting is disabled; doing nothing."

  _logAction: (verb, object) =>
    if @isCurrentlyLogging and @actionLogger
      @actionLogger.log(verb, object)

  _init: () =>
    # edge button
    $("#ut_tools_conceptmapper_linkButton").click () =>
      if @mode is @LINK_MODE
        @setMode(@NODE_MODE)
      else
        @setMode(@LINK_MODE)
    # load/save
    @storage = new ut.commons.persistency.FileStorage()
    $("#ut_tools_conceptmapper_store").click @saveConceptMap
    $("#ut_tools_conceptmapper_retrieve").click @loadConceptMap
    # tooltips
    #$(".tiptip").tipTip {
    # defaultPosition: "right"
    #}
    @_initDnD()
    @_initJsPlumb()
    if window.notificationClient isnt undefined
      window.notificationClient.register @notificationPremise, @consumeNotification
      console.log "ConceptMapper.init: notificationClient found and registered."
    else
      console.log "ConceptMapper.init: notificationClient not found."

  notificationPremise: (notification) =>
    # TODO do some filtering
    # return true only of e.g. targetId matches
    return true

  _initDnD: () =>
    # make the toolbar-concepts draggable
    $("#ut_tools_conceptmapper_toolbar .ut_tools_conceptmapper_concept").draggable({
      helper: "clone",
      cursor: "move",
      containment: "#ut_tools_conceptmapper_root"
    })
    $("#ut_tools_conceptmapper_map").bind 'dragover', (event) ->
      return false
    $("#ut_tools_conceptmapper_map").droppable()
    # handle the drop...
    $("#ut_tools_conceptmapper_map").bind 'drop', (event, ui) =>
      #console.log "ui: "+ui
      #console.log "ui.draggable: "+ui.draggable
      #console.log "dataTransfer: "+event.originalEvent.dataTransfer
      #console.log "types: "+event.originalEvent.dataTransfer.types
      #console.log "files: "+event.originalEvent.dataTransfer.files

      if (ui and $(ui.draggable).hasClass("ut_tools_hypothesis_condition"))
        return false
      else if (ui and $(ui.draggable).hasClass("ut_tools_conceptmapper_template"))
        if @configuration.debug.value is "true" then console.log("Concept template dropped. Clone and add to map.")
        if ($(ui.draggable).hasClass("ut_tools_conceptmapper_conceptTextarea"))
          @sendCreateConcept(ut.commons.utils.generateUUID(), $(ui.draggable).text(), ui.position.left, ui.position.top, "ut_tools_conceptmapper_conceptTextarea")
        else if ($(ui.draggable).hasClass("ut_tools_conceptmapper_conceptSelector"))
          @sendCreateConcept(ut.commons.utils.generateUUID(), $(ui.draggable).text(), ui.position.left, ui.position.top, "ut_tools_conceptmapper_conceptSelector")
      else if (event.originalEvent.dataTransfer)
        #console.log event.originalEvent.dataTransfer
        #console.log event.originalEvent.dataTransfer.types
        #console.log event.originalEvent.dataTransfer.files
        if @configuration.drop_external.value is "true"
          @sendCreateConcept(ut.commons.utils.generateUUID(), event.originalEvent.dataTransfer.getData("Text"), event.originalEvent.clientX, event.originalEvent.clientY, "ut_tools_conceptmapper_conceptTextarea")
      return false
    # make the trashcan work
    $("#ut_tools_conceptmapper_trashcan").click @onClickHandlerTrashcan
    $("#ut_tools_conceptmapper_trashcan").droppable {
      accept: ".ut_tools_conceptmapper_concept",
      drop: (event, ui) =>
        @sendRemoveConcept(ui.draggable)
    }
    $("#ut_tools_conceptmapper_notification").click () =>
      notificationPrompt = {
        type: "prompt"
        content: {
          text: "The selection of pre-defined concepts has been changed."
        }
      }
      notificationConfiguration = {
        type: "configuration"
        content: {
          configuration: {
            concepts: {
              value: ["length", "mass", "time"]
            }
          }
        }
      }
      @consumeNotification(notificationPrompt)
      @consumeNotification(notificationConfiguration)
    $("#ut_tools_conceptmapper_settings").click () =>
      new ut.tools.conceptmapper.ConfigDialog @configuration, @configure

  _initJsPlumb: () =>
    jsPlumbDefaults = {
      Connector : [ "Bezier", { curviness:500 } ],
      ConnectorZIndex: 0,
      DragOptions : { cursor: "pointer", zIndex:2000 },
      PaintStyle : { strokeStyle:"#00b7cd" , lineWidth:4 },
    #EndpointStyle : { radius:5, fillStyle:"#00b7cd" },
      EndpointStyle : {},
    #HoverPaintStyle : {strokeStyle:"#92d6e3" },
    #EndpointHoverStyle : {fillStyle:"#92d6e3" },
    #EndpointHoverStyle : {},
      Anchor: [ "Perimeter", { shape:"Ellipse"} ],
      ConnectionOverlays: [
        [ "Arrow", { location:0.7 }, { foldback:0.7, fillStyle:"#00b7cd", width:20 }],
        [ "Label", { label: @configuration.relations.value[0], location:0.5, id:"label" }]
      ],
      Detachable:false,
      Reattach:false
    }
    jsPlumb.importDefaults jsPlumbDefaults
    jsPlumb.setRenderMode jsPlumb.SVG
    jsPlumb.unbind "jsPlumbConnection"
    jsPlumb.bind "jsPlumbConnection", (event) =>
      # new connection has been created
      event.connection.getOverlay("label").bind("click", @onClickHandlerConnectionLabel)
      # log
      object = {
        "objectType": "relation",
        "id": event.connection.id
        "content": event.connection.getOverlay("label").getLabel(),
        "source": event.connection.sourceId,
        "target": event.connection.targetId
      }
      @_logAction("add", object)

  initConceptMapDropHandler: () ->
    #decide whether the thing dragged in is welcome
    $("#ut_tools_conceptmapper_map").bind 'dragover', (ev) ->
      return false
    $("#ut_tools_conceptmapper_map").droppable()
    $("#ut_tools_conceptmapper_map").bind 'drop', (event, ui) ->
      if ui and $(ui.draggable).hasClass("ut_tools_hypothesis_condition")
        return false
      else if ui and $(ui.draggable).hasClass("ut_tools_conceptmapper_template")
        if @configuration.debug.value is "true" then console.log("Concept template dropped. Clone and add to map.")
      else if (event.originalEvent.dataTransfer)
        sendCreateConcept(ut.commons.utils.generateUUID(), event.originalEvent.dataTransfer.getData("Text"), event.originalEvent.clientX, event.originalEvent.clientY, "ut_tools_conceptmapper_conceptTextarea")
      return false

  sendCreateConcept: (id, conceptText, x, y, className) ->
    @createConcept(id, conceptText, x, y, className)
    concept = @getConceptById(id)
    @socket.emit("createConcept", JSON.stringify(concept))

  createConcept: (id, conceptText, x, y, className) ->
    newConcept = $("<div>")
    newConcept.attr('id', id)
    newConcept.addClass("ut_tools_conceptmapper_concept")
    newConcept.append($('<p/>').html(nl2br(conceptText)))
    jsPlumb.draggable newConcept, {
      containment: "#ut_tools_conceptmapper_root",
      cursor: "move",
      revert: "invalid",
      iframeFix: true,
      delay: 50,
      start: () ->
        window.mySocket.emit("startMoveConcept", id)
#        console.log "Start dragging ..." + id
      drag: (event, ui) ->
#        console.log "dragging ..."
#        jsPlumb.repaintEverything()
        data = {"id":id, "x":newConcept.css('left'), "y":newConcept.css('top')}
        window.mySocket.emit("dragConcept", JSON.stringify(data))
      stop: (event, ui) ->
#        console.log "Stop dragging ..." + id
        data = {"id":id, "x":newConcept.css('left'), "y":newConcept.css('top')}
        window.mySocket.emit("stoptMoveConcept", JSON.stringify(data))
    }
    newConcept.css('position', 'absolute');
    newConcept.css('top', y);
    newConcept.css('left', x);
    newConcept.addClass(className);

    if className is "ut_tools_conceptmapper_conceptTextarea"
      newConcept.click(@onClickHandlerInjectTextarea)
    else
      newConcept.click(@onClickHandlerInjectCombobox)
    $("#ut_tools_conceptmapper_map").append(newConcept)
    if (@mode == @LINK_MODE) then @setConceptLinkMode(newConcept)
    else if (@mode == @LINK_MODE) then @setConceptNodeMode(newConcept)

    # logging
    logObject = {
      "objectType": "concept",
      "id": id,
      "content": conceptText
    }
    @_logAction("add", logObject)

  getConceptById: (id) ->
    concepts = @getConcepts()
    for concept in concepts
      if concept.id == id
        return(concept)

  conceptExists: (id) ->
    concepts = @getConcepts()
    for concept in concepts
      if concept.id == id
        return(true)
    return false

  getConcepts: () ->
    concepts = []
    $.each $("#ut_tools_conceptmapper_map .ut_tools_conceptmapper_concept"), (index, node) ->
      concept = {}
      concept.x = $(node).offset().left
      concept.y = $(node).offset().top
      concept.content = $(node).find("p").text()
      concept.id = $(node).attr("id")
      if $(node).hasClass("ut_tools_conceptmapper_conceptSelector")
        concept.type = "ut_tools_conceptmapper_conceptSelector"
      else
        concept.type = "ut_tools_conceptmapper_conceptTextarea"
      concepts.push(concept)
    return(concepts)

  moveConcept: (id, x, y) ->
    $.each $("#ut_tools_conceptmapper_map .ut_tools_conceptmapper_concept"), (index, concept) =>
      if id == $(concept).attr("id")
        $(concept).css('top', y);
        $(concept).css('left', x);
        jsPlumb.repaintEverything()

  updateConceptContent: (id, content) ->
    $.each $("#ut_tools_conceptmapper_map .ut_tools_conceptmapper_concept"), (index, concept) =>
      if id == $(concept).attr("id")
        p = $('<p/>').html(content)
        $(concept).find("p").replaceWith(p)
        jsPlumb.repaintEverything()

  updateRelationLabel: (id, content) ->
    conn = @getConnectionById(id)
    label = conn.getOverlay("label")
    label.setLabel(content)

  onClickHandlerInjectTextarea: (event) =>
    #lock event
    if @mode is @LINK_MODE
      # we are in link mode, delegate event
      @onClickEdgeHandler(event)
    else if not $(event.target).is("div")
      # no textarea found -> replace paragraph with textarea
      $p = $(event.target)
      textarea = $('<textarea/>').val($p.text())
      @contentBeforeEdit = $p.text()
      textarea.autogrow()
      $p.replaceWith(textarea)
      textarea.on("blur", @onBlurHandlerInjectParagraph)
      # detach this listener
      #$(event.currentTarget).off("click")
      textarea.focus()

  onClickHandlerInjectCombobox: (event) =>
    #lock event
    if (@mode is @LINK_MODE)
      # we are in link mode, delegate event
      @onClickEdgeHandler(event)
    else if not $(event.target).is("div")
      # no input found -> replace paragraph with textarea
      $p = $(event.target)
      inputField = $('<input/>').val($p.text())
      @contentBeforeEdit = $p.text()
      inputField.autocomplete {
        source: @configuration.concepts.value,
        minLength: 0
      }
      $p.replaceWith(inputField)
      inputField.blur(@onBlurHandlerInjectParagraph)
      inputField.autocomplete('search', '')
      inputField.focus()

  onClickHandlerConnectionLabel: (label) =>
    if $("#"+label.canvas.id).find("input").length
      # the combobox has already been created,
      # open the search fields
      $("#"+label.canvas.id).find("input").autocomplete('search', '')
    else
      @editingLabel = label
      inputField = $('<input/>').val(@editingLabel.getLabel())
      @labelBeforeEdit = @editingLabel.getLabel()
      inputField.autocomplete {
        source: @configuration.relations.value,
        minLength: 0
      }
      # empty the div
      $("#"+label.canvas.id).text("")
      # and inject the input field / selector
      inputField.addClass("_jsPlumb_overlay")
      inputField.css("text-align","left")
      inputField.css("font-size", "medium")
      $("#"+label.canvas.id).append(inputField)
      inputField.blur(@onBlurHandlerInjectRelation)
      inputField.autocomplete('search', '')
      inputField.focus()
      jsPlumb.repaintEverything()

  onBlurHandlerInjectRelation: (event) =>
    newLabel = nl2br($(event.target).val())
    @editingLabel.setLabel(newLabel)
    $(event.target).parent().text(@editingLabel.getLabel())
    $(event.target).remove()
    # @editingLabel = null;
    # repaint the links, as the size of the concept element might have changed
    jsPlumb.repaintEverything()
    if newLabel isnt @labelBeforeEdit
      object = {
        "objectType": "relation",
        "id": @editingLabel.component.id
        "content": newLabel
      }
      data = {"id":@editingLabel.component.id, "content": newLabel}
      @socket.emit("updateRelationLabel", JSON.stringify(data))
      @_logAction("update", object)
    @labelBeforeEdit = ""
    @editingLabel = undefined

  onBlurHandlerInjectParagraph: (event) =>
    # replace the input element (e.g. textArea) with paragraph
    inputElement = $(event.target)
    newContent = nl2br(inputElement.val())
    p = $('<p/>').html(newContent)
    inputElement.replaceWith(p)
    # repaint the links, as the size of the concept element might have changed
    jsPlumb.repaintEverything()
    # log
    if (newContent isnt @contentBeforeEdit)
      object = {
        "objectType": "concept",
        "id": p.parent().attr("id"),
        "content": newContent
      }
      data = {"id":p.parent().attr("id"), "content": newContent}
      @socket.emit("updateConceptContent", JSON.stringify(data))
      @_logAction("update", object)
    @contentBeforeEdit = ""

  sendRemoveConcept: (concept) ->
    id = $(concept).attr("id")
    @removeConcept(concept)
    @socket.emit("deleteConcept", id)

  removeConcept: (concept) =>
    id = $(concept).attr("id")
    #jsPlumb.select({source:id}).detach()
    #jsPlumb.select({target:id}).detach()
    # delete connections explicetly (for logging)
    @deleteConnectionsBetween(id)
    $(concept).fadeOut 300, =>
      $(concept).remove()
      # log
      object = {
        "objectType": "concept",
        "id": id
      }
      @_logAction("delete", object)

  onClickHandlerTrashcan: () =>
    $("#ut_tools_conceptmapper_dialog").text("Do you really want to delete all concepts and relations?")
    $("#ut_tools_conceptmapper_dialog").dialog {
      title: "Remove everything?",
      resizable: false,
      modal: true,
      autoOpen: false,
      height: 110,
    #position: position: { my: "center", at: "center"},
      closeOnEscape: false,
    #open: (event, ui) ->
    #beforeclose: (event, ui) -> false
      dialogClass: "ut_tools_conceptmapper_dialog",
      buttons: {
        "Yes": () =>
          @sendDeleteAll()
          $("#ut_tools_conceptmapper_dialog").dialog("close")
        "No": () =>
          $("#ut_tools_conceptmapper_dialog").dialog("close")
      }
    }
    # open dialog now and remove focus from buttons
    $('#ut_tools_conceptmapper_dialog').dialog('open')
    $('.ui-dialog :button').blur()

  sendDeleteAll: () ->
    @socket.emit("deleteAll")
    @deleteAll()

  deleteAll: () =>
    $.each $("#ut_tools_conceptmapper_map .ut_tools_conceptmapper_concept"), (index, concept) =>
      @removeConcept(concept)

  setMode: (newMode) ->
    if (newMode is @mode)
      # if the new mode is actually not new, do nothing...
      return
    else
      switch newMode
        when @NODE_MODE
          $("#ut_tools_conceptmapper_map").find(".ut_tools_conceptmapper_concept").each (index, concept) => @setConceptNodeMode(concept)
          $(".ut_tools_conceptmapper_template").removeClass("ut_tools_conceptmapper_lowLight")
          $("#ut_tools_conceptmapper_linkButton").removeClass("pressedButton")
          $("#ut_tools_conceptmapper_linkButton").addClass("activeButton")
          jsPlumb.unmakeEverySource()
          jsPlumb.unmakeEveryTarget()
          $(@sourceNode).removeClass("highlight_concept")
          $(@targetNode).removeClass("highlight_concept")
          @sourceNode = undefined
          @targetNode = undefined
          @mode = newMode
        when @LINK_MODE
          $("#ut_tools_conceptmapper_map").find(".ut_tools_conceptmapper_concept").each (index, concept) => @setConceptLinkMode(concept)
          # $("#ut_tools_conceptmapper_map").find(".ut_tools_conceptmapper_concept").draggable("disable")
          $(".ut_tools_conceptmapper_template").addClass("ut_tools_conceptmapper_lowLight")
          $("#ut_tools_conceptmapper_map").find(".ut_tools_conceptmapper_concept").css("opacity","1.0")
          $("#ut_tools_conceptmapper_linkButton").addClass("pressedButton")
          $("#ut_tools_conceptmapper_linkButton").removeClass("activeButton")
          @mode = newMode
        else
          console.log("ConceptMapper.setMode: unrecognized mode #{newMode} doing nothing.")

  setConceptNodeMode: (concept) =>
    $(concept).draggable("enable")

  setConceptLinkMode: (concept) =>
    $(concept).draggable("disable")
    jsPlumb.makeSource concept, {}
    jsPlumb.makeTarget concept, {
      dropOptions:{ hoverClass:"jsPlumbHover" },
      beforeDrop: (params) =>
        if (params.sourceId is params.targetId)
          if @configuration.debug.value is "true" then console.log "Creating edges between same source and target is disallowed."
          return false
        else
          if @connectionExists(params.sourceId, params.targetId)
            if @configuration.debug.value is "true" then console.log "An edge between concepts already exists -> delete it (instead of create a new one)."
            @sendDeleteConnectionsBetween(params.sourceId, params.targetId)
            return false
          else
            if @configuration.debug.value is "true" then console.log "All conditions met, create a new edge."
            return true
    }

  onClickEdgeHandler: (event) =>
    if @sourceNode is undefined
      @sourceNode = event.currentTarget
      $(@sourceNode).toggleClass("highlight_concept")
    else
      if event.currentTarget is @sourceNode
        $(event.currentTarget).toggleClass("highlight_concept")
        @sourceNode = undefined
      else
        @targetNode = event.currentTarget
    if (@sourceNode isnt undefined) and (@targetNode isnt undefined)
      sourceId = $(@sourceNode).attr("id")
      targetId = $(@targetNode).attr("id")
      if @connectionExists(sourceId, targetId)
        @sendDeleteConnectionsBetween(sourceId, targetId)
      else
        if @configuration.debug.value is "true" then console.log "Connection does not exist -> create."
        #connection = jsPlumb.connect({source:@sourceNode, target:@targetNode})
        connection = jsPlumb.connect({source:sourceId, target:targetId})
        data = {source:sourceId, target:targetId}
        @socket.emit("createRelation", JSON.stringify(data))
      #connection.getOverlay("label").setLabel(@configuration.relations[0])
      $(@sourceNode).removeClass("highlight_concept")
      $(@targetNode).removeClass("highlight_concept")
      @sourceNode = undefined
      @targetNode = undefined
      jsPlumb.repaintEverything()

  connectionExists: (sourceId, targetId) =>
    existingConnections = jsPlumb.getConnections {source:sourceId, target:targetId}
    existingConnections = existingConnections.concat jsPlumb.getConnections({source:targetId, target:sourceId})
    return existingConnections.length > 0

  sendDeleteConnectionsBetween: (sourceId, targetId) =>
    @deleteConnectionsBetween(sourceId, targetId)
    data = {source:sourceId, target:targetId}
    @socket.emit("deleteRelation", JSON.stringify(data))

  deleteConnectionsBetween: (sourceId, targetId) =>
    connections = jsPlumb.getConnections({source:sourceId, target:targetId})
    connections = connections.concat jsPlumb.getConnections({source:targetId, target:sourceId})
    for connection in connections
      jsPlumb.detach(connection)
      #log
      object = {
        "objectType": "relation",
        "id": connection.id
      }
      @_logAction("delete", object)

  getConnectionById: (id) ->
    for connection in jsPlumb.getConnections()
      if connection.id == id
        return connection

  getConceptMapAsJSon: () ->
    conceptMap = {}
    conceptMap.user = @user if not undefined
    conceptMap.meta = @meta
    # create the nodes
    concepts = []
    $.each $("#ut_tools_conceptmapper_map .ut_tools_conceptmapper_concept"), (index, node) ->
      concept = {}
      concept.x = $(node).offset().left
      concept.y = $(node).offset().top
      concept.content = $(node).find("p").text()
      concept.id = $(node).attr("id")
      if $(node).hasClass("ut_tools_conceptmapper_conceptSelector")
        concept.type = "ut_tools_conceptmapper_conceptSelector"
      else
        concept.type = "ut_tools_conceptmapper_conceptTextarea"
      concepts.push(concept)
    conceptMap.concepts = concepts
    # create the edges
    relations = [];
    for connection in jsPlumb.getConnections()
      relation = {}
      relation.source = connection.sourceId
      relation.target = connection.targetId
      relation.id = connection.id
      relation.content = connection.getOverlay("label").getLabel()
      relations.push(relation)
    conceptMap.relations = relations
    return conceptMap

  saveConceptMap: () =>
    map = @getConceptMapAsJSon()
#    @storage.storeAsFile(map, "conceptmap.json")
    # logging
    object = {
      "objectType": "conceptMap",
      "content": map
      "id": @meta.target.id
    }
    @socket.emit("saveConcept", JSON.stringify(map))
    @_logAction("save", object)


  loadConceptMap: () =>
#    @storage.getJSonObjectFromDialog (errorMsg, jsonObject) =>
#      if (errorMsg)
#        console.log "Error loading from file: #{errorMsg}."
#      else
#        if jsonObject.meta.generator.displayName is "ut.tools.conceptmapper"
#          @setConceptMapFromJSON(jsonObject)
#        else
#          alert("Could not load file.\nIs it really a concept map file?")
    #TODO implement a load from server method instead
    @socket.emit "loadConcept"

  setConceptMapFromJSON: (conceptMap) ->
    @isCurrentlyLogging = false
    # delete everything
    @deleteAll()
    @meta = conceptMap.meta
    # create the nodes
    for concept in conceptMap.concepts
      @createConcept(concept.id, concept.content, concept.x, concept.y, concept.type)
    # create the edges
    for relation in conceptMap.relations
      connection = jsPlumb.connect({source:relation.source, target:relation.target})
      connection.id = relation.id
      connection.getOverlay("label").setLabel(relation.content)
    @isCurrentlyLogging = true
    jsPlumb.repaintEverything()
    # log
    map = {
      "concepts": conceptMap.concepts,
      "relations": conceptMap.relations
    }
    object = {
      "objectType": "conceptMap",
      "content": map
      "id": @meta.target.id
    }
    @_logAction("load", object)

#    @constructor.socket.on 'sendConcept', (data) ->
#      console.log "Lets LOAD SOME DATA!!"
#      console.log data
#    $scope.ConceptMapperCtrl.setConceptMapFromJSON(data)

window.ut.tools.conceptmapper.ConceptMapper.$inject = ["$scope", "Socket"]
angular.module('myApp').controller("ConceptMapperCtrl", window.ut.tools.conceptmapper.ConceptMapper)
