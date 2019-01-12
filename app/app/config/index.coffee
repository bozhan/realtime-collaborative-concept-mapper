exports.setEnv = (environment) ->

  ###
    Common config
  ###
  exports.HOSTNAME = "localhost"
  exports.PORT = 8010
  exports.PUBLIC_PATH = "public"
  exports.VIEWS_ENGINE = "jade"
  exports.VIEWS_PATH = "views"
  exports.IMAGES_PATH = "images"
  exports.DATA_PATH = "data"

  ###
    Environment specific config
  ###
  switch environment
    when "development"
      null

    when "testing"
      null

    when "production"
      null

    else
      console.log "Unknown environment #{environment}!"
