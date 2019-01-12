"use strict"

window.ils ?= {}
window.ils.storage ?= {}
window.ils.storage.memory ?= {}

###
  Superclass for all storage handlers
###
class window.ils.storage.StorageHandler

  constructor: (actor, target, generator, provider) ->
    console.log "Initializing StorageHandler."
    @_debug = true
    @_actor = actor
    @_target = target
    @_generator = generator
    @_provider = provider

  getActor: () =>
    @_actor

  setActor: (actor) =>
    @_actor = actor
    @

  getTarget: () =>
    @_target
    @

  setTarget: (target) =>
    @_target = target

  getGenerator: () =>
    @_generator
    @

  setGenerator: (generator) =>
    @_generator = generator

  getProvider: () =>
    @_provider
    @

  setProvider: (provider) =>
    @_provider = provider

  getResourceBundle: (content) =>
    resource = {}
    resource.id = ut.commons.utils.generateUUID()
    resource.metadata = {}
    resource.metadata.published = new Date().toISOString()
    resource.metadata.author = @_actor
    resource.metadata.target = @_target
    resource.metadata.generator = @_generator
    resource.metadata.provider = @_provider
    resource.content = content
    resource

  ###
    Reads a resource with a given id.
    Returns a json object {id, metadata{}, content{}}
    Returns undefined if resourceId cannot be found
  ###
  readResource: (resourceId) ->
    throw "Abtract function - implement in subclass."

  ###
    Creates a resource with the given content.
    Returns a json object {id, metadata{}, content{}}
    Returns undefined if something went wrong
  ###
  createResource: (content) =>
    throw "Abtract function - implement in subclass."

  ###
    Updates an existing resource with new content.
    Returns a json object {id, metadata{}, content{}}
    Returns undefined if something went wrong
  ###
  updateResource: (resourceId, content) ->
    throw "Abtract function - implement in subclass."

  ###
    Lists all existing resources
    Returns an array with existing resourceId's
  ###
  listResourceIds: () ->
    throw "Abtract function - implement in subclass."


###
  The actual implementation of the MemoryStorageHandler
###
class window.ils.storage.MemoryStorageHandler extends window.ils.storage.StorageHandler
  constructor: ->
    super
    console.log "Initializing MemoryStorageHandler."
    @

  readResource: (resourceId) ->
    if window.ils.storage.memory[resourceId]
      if @_debug then console.log "MemoryStorage: readResource #{resourceId}"
      return window.ils.storage.memory[resourceId]
    else
      if @_debug then console.log "MemoryStorage: readResource #{resourceId} not found."
      return undefined

  createResource: (content) =>
    try
      # create resource with id, metadata and content
      resource = @getResourceBundle(content)
      if window.ils.storage.memory[resource.id]
        if @_debug then console.log "MemoryStorage: resource already exists! #{resource.id}"
        return undefined
      else
        window.ils.storage.memory[resource.id] = resource
        if @_debug then console.log "MemoryStorage: resource created: #{resource}"
        if @_debug then console.log resource
        return resource
    catch error
      if @_debug then console.log "MemoryStorage: resource NOT created: #{error}"
      return undefined

  updateResource: (resourceId, content) ->
    if window.ils.storage.memory[resourceId]
      # create resource with id, metadata and content
      resource = @getResourceBundle(content)
      window.ils.storage.memory[resourceId] = resource
      console.log "MemoryStorage: updateResource #{resourceId}"
      return resource
    else
      console.log "MemoryStorage: updateResource failed, resource doesn't exist: #{resourceId}"
      return undefined

  listResourceIds: () ->
    id for id, resource of window.ils.storage.memory