_ = require 'lodash'

connected = false
queue     = []
socket    = null

sendQueue = ->
  if !connected then return
  try
    for m in queue
      socket.send JSON.stringify m
    queue = []
  catch e
    console.error 'Failed to send message to recorder server.', e

send = (msg) ->
  msg.timestamp = _.now()
  queue.push msg
  sendQueue()

window.addEventListener 'DOMContentLoaded', ->

  socket = new WebSocket 'ws://localhost:5226'
  socket.onopen = ->
    console.log 'WebSocket connected.'
    connected = true
    sendQueue()
  socket.onclose = ->
    alert 'Recorder server connection closed, or failed to connect.'

module.exports =
  send: send
