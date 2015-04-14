express = require 'express'
app = express()

app.set 'views', './www/views'
app.set 'view engine', 'jade'

app.use '/js', express.static('www/js')
app.use '/css', express.static('www/css')

app.get '/', (req, res) ->
  res.render 'index'

app.get '/sui', (req, res) ->
  res.render 'sui'

server = app.listen 3000, ->

  host = server.address().address
  port = server.address().port

  console.log "Trial server listening at http://%s:%s", host, port
