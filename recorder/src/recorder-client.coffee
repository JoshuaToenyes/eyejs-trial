_ = require 'lodash'

nodeIndex = (node) ->
  i = 0
  if node.parentNode and node.parentNode.children
    for c in node.parentNode.children
      if c is node then return i
      i++
  return i

serializeNode = (node) ->
  if !node then return ''
  tagName = node.tagName
  id = if node.id then "##{node.id}" else ''
  serialized = "#{tagName}#{id}"
  if node.parentNode isnt document
    index = nodeIndex node
    serialized = serializeNode(node.parentNode) + "/#{index}-#{serialized}"
  return serialized.toLowerCase()

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

  send event: 'DOMContentLoaded', location: window.location.href

  window.addEventListener 'load', ->
    send event: 'load', location: window.location.href

  window.addEventListener 'unload', ->
    send event: 'unload', location: window.location.href

  sendMouseEvent = (type, e) ->
    msg =
      event:   type
      screenX: e.screenX
      screenY: e.screenY
      clientX: e.clientX
      clientY: e.clientY
      element: serializeNode e.target
    send msg

  document.body.addEventListener 'mouseup', (e) ->
    sendMouseEvent 'mouseup', e

  document.body.addEventListener 'mousedown', (e) ->
    sendMouseEvent 'mousedown', e

  document.body.addEventListener 'mousemove', (e) ->
    sendMouseEvent 'mousemove', e

module.exports =
  send: send
  serializeNode: serializeNode
