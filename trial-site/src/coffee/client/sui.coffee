_ = require 'lodash'

recorder = require './../../recorder/dist/recorder-command'

# The number of buttons to render
COUNT = 12

ALPHABET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split ''

MARGINS = [20, 10, 2]

SEQUENCE_LENGTH = 4

REDUCE_FACTOR = 0.5

MIN_SIZE = 10

currentSize = 250
currentMarginIndex = MARGINS.length - 1
selectionSequence = null
data = {}
activeTask = null

generateSequence = (length=COUNT) ->
  _.shuffle(ALPHABET).splice 0, length

renderBlocks = (size, margin, sequence) ->
  labels = _.shuffle sequence
  $blocks = $('#blocks')
  $blocks.empty()
  i = 0
  $row = null
  for l in labels
    if i++ % 4 is 0
      $row = $('<div>')
      $blocks.append $row
    $button = $('<button>').text(l).css
      height: size + 'px'
      width: size + 'px'
      margin: margin + 'px'
    $button.attr 'data-eyejs-snap', ''
    if currentSize < 25
      $button.css 'font-size', '0.9em'
    if currentSize < 20
      $button.css 'font-size', '0.7em'
    $row.append $button
  $('button').click check
  mt = $(window).height() / 2 - $('#blocks-container').height() / 2 - 100
  $('#blocks-container').css 'margin-top', mt

renderSelectionSequence = (sequence) ->
  $('#sequence').empty()
  for s in sequence
    $l = $('<span>').html s
    $l.attr 'data-ss', s
    $('#sequence').append $l

next = ->
  currentMarginIndex = (currentMarginIndex + 1) % MARGINS.length
  nextMargin = MARGINS[currentMarginIndex]
  if currentMarginIndex is 0 then currentSize *= REDUCE_FACTOR
  $blocks = $('#blocks')
  sequence = generateSequence()
  renderBlocks(currentSize, nextMargin, sequence)
  selectionSequence = sequence.splice 0, SEQUENCE_LENGTH
  renderSelectionSequence selectionSequence
  data[currentSize] ?= {}
  data[currentSize][nextMargin] =
    correct: 0
    incorrect: 0
  activeTask = data[currentSize][nextMargin]
  if currentSize < MIN_SIZE then done()

timer = null

restartTimer = ->
  clearTimeout timer
  timer = setTimeout ->
    done()
  , 30000

check = (e) ->
  e.stopPropagation()
  $el = $(e.target)
  l = $el.text()
  if l is selectionSequence[0]
    $el.addClass 'correct'
    $("#sequence [data-ss='#{l}']").addClass('correct')
    selectionSequence.shift()
    activeTask.correct++
  else
    $el.addClass 'wrong'
    activeTask.incorrect++
    setTimeout ->
      $el.removeClass 'wrong'
    , 1000
  calculateAccuracy()
  if selectionSequence.length is 0 then next()

done = ->
  $('#sequence').remove()
  $('#blocks').remove()
  $('#done').show()
  data.event = 'sui-complete'
  recorder.send data

calculateAccuracy = ->
  restartTimer()
  count = (activeTask.correct + activeTask.incorrect)
  acc = activeTask.correct / count
  if acc < 0.4 and count > 4 then done()


$ ->
  next()
  $('button.done').click -> self.close()
  $('body').click ->
    activeTask.incorrect++
    calculateAccuracy()
