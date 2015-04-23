_ = require 'lodash'

recorder = require './../../recorder/dist/recorder-command'

$ ->
  OFF_OPACITY = 0.1

  options = [
    ''
    'checks'
    'naughty'
    'North Pole'
    'lap'
    'cards'
    'sleigh'
    'coal'
    'nice'
    'beard'
    'decorate'
    'baked'
    'presents'
    'holiday'
    'toys'
    'sing'
    'elves'
    'turkey'
    'under'
    'reindeer'
    'merry'
    'fills'
    'Eve'
    'workshop'
    'lights'
    'chimney'
    'family'
    'spirit'
  ]

  regex = /_(\w+)_/g

  tstart = _.now()

  $select = $('<select>')
  _.each options, (option) ->
    option = option.replace '_', ' '
    $select.append $('<option>').val(option).text(option)
  $select = $('<div>').append $select

  _.each ['#content1', '#content2'], (c) ->
    $el = $(c)
    while (match = regex.exec($el.html()))
      $clone = $select.clone()
      $clone.find('select').attr('data-correct', match[1].replace '_', ' ')
      $el.html($el.html().replace match[0], $clone.html())

  fadingEnabled = /with\-fading/.test window.location.search
  content1 = /content1/.test window.location.search

  if fadingEnabled
    $('aside').css 'opacity', OFF_OPACITY

    $('aside').on 'gaze', ->
      $(this).css 'opacity', 1

    $('aside').on 'gazeleave', ->
      $(this).css 'opacity', OFF_OPACITY

  else
    $('aside').css 'opacity', 1

  if content1
    $('#content1').show()
    selector = '#content1 select'
  else
    $('#content2').show()
    selector = '#content2 select'

  $('button.done').click ->
    sendResults()
    self.close()

  sendResults = ->
    results =
      tstart:   tstart
      tend:     _.now()
      selected: $(selector).length
      correct:  0
    _.each $(selector), (sel) ->
      if $(sel).val() is $(sel).attr('data-correct')
        results.correct++
    recorder.send results

  setInterval ->
    allDone = true
    _.each $(selector), (sel) ->
      if $(sel).val() is ''
        allDone = false
        return false
    if allDone then $('button.done').show()
  , 100
