#mathjs = require 'mathjs'

_ = require 'lodash'

window.trial = trial =
  id: _.random 1, 1e9
  start: null
  stop: null
  info: {}
  experiments: {}

$ ->
  $('.next').click ->
    parentView = $(this).parents('.view')
    parentView.addClass('hide')
    parentView.next('.view').addClass('show').removeClass('hide')

  $('.previous').click ->
    parentView = $(this).parents('.view')
    parentView.addClass('hide')
    parentView.prev('.view').addClass('show').removeClass('hide')

  # Record the start time when the start button is clicked.
  $('button.start').click ->
    trial.start = _.now()

  # Every time a button is clicked, save all the info to the `trial`
  # object.
  $('button.next').click ->
    $('input').each (i, el) ->
      trial.info[el.id] = $(el).val()

  # Generate the order of experiements
  experiments = _.shuffle ['s', 'w', 'a', 'f']

  # Generate input-orders
  _.each experiments, (e) ->
    trial.experiments[e] = _.shuffle ['m', 'k', 'b']

  # Randomize the experiment buttons.
  _.each experiments, (e) ->
    el = $("#e_#{e}").detach()
    $('#experiments').append(el)
  # Put Natural Use at the bottom.
  $('#experiments').append $('#e_n')
