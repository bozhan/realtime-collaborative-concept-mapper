
#GET home page
exports.index = (request, response) ->
  response.render "index"

exports.log = (request, response) ->
  fs = require 'fs'
#  qs = require 'querystring'

  if request.method == 'POST'
#    console.log request.body
    filename = "./log/log.json"
#    response.post = querystring.parse(queryData)
    fs.appendFile filename, JSON.stringify(request.body) + ",", (err) ->
      if (err)
        console.log err
      else
        response.send "JSON accepted"
