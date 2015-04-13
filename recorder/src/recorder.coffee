##
#

PORT = 5226

WebSocketServer = require('websocket').server
http            = require 'http'
fs              = require 'fs'
moment          = require 'moment'

# Create a blank HTTP server that always returns a 404.
server = http.createServer (req, res) ->
  response.writeHead 404
  res.end()

# Start the HTTP server listening on the specified port.
server.listen PORT, ->
  console.log "Server is listening on port #{PORT}"

# Create a very simple WebSocket server that accepts all incoming connections.
wsServer = new WebSocketServer
  httpServer: server
  autoAcceptConnections: false

output = null
open = false
filename = null

openNewFile = ->
  closeOpenFile()
  filename = moment().format('MM-D-YYYY-HH-mm-ss') + '.log'
  console.log 'Opening new log file: ', filename
  output = fs.createWriteStream './' + filename
  open = true

closeOpenFile = ->
  if open
    console.log 'Closing open log file: ', filename
    output.end()
    open = false

process.on 'SIGINT', ->
  closeOpenFile()
  process.exit()

wsServer.on 'request', (req) ->
  console.log 'Incoming server request...'
  connection = req.accept null, req.origin
  console.log 'New connection accepted.'
  connection.on 'message', (msg) ->
    if msg.type is 'utf8'
      m = JSON.parse msg.utf8Data

      if m.event is 'participant start'
        openNewFile()

      if open then output.write msg.utf8Data + '\n', 'utf8'

      if m.event is 'participant end'
        closeOpenFile()

    else
      console.log 'Received non-UTF8 message!'
  connection.on 'close', (reason, description) ->
    console.log 'Connection closed.'
