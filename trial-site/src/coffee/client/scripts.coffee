#mathjs = require 'mathjs'

_ = require 'lodash'

recorder = require './../../recorder/dist/recorder-command'

window.trial = trial =
  id: _.random 1, 1e9
  start: null
  stop: null
  info: {}
  experiments: {}

INPUT_MAP =
  k: 'Eyes &amp; Keypress'
  m: 'Standard Mouse &amp; Keyboard'
  b: 'Eyes Only'

show = ($el, right) ->
  hideClass = 'hide'
  if right then hideClass = 'hide right'
  $('.view.show').removeClass('show right').addClass(hideClass)
  $el.removeClass('hide').addClass('show')
  $('.wrapper').animate({ scrollTop: "0px" })

$ ->

  # Stop recording if we refresh the page, or start over.
  recorder.send event: 'stop recording'

  window.onbeforeunload = ->
    "Whoa! Are you sure you want to leave?"

  $('.next').click ->
    parentView = $(this).parents('.view')
    show parentView.next('.view')

  $('.previous:not(.experiment)').click ->
    parentView = $(this).parents('.view')
    show parentView.prev('.view'), true


  # Record the start time when the start button is clicked.
  $('button.participant-start').click ->
    trial.start = _.now()
    recorder.send event: 'participant start'

  # Every time a button is clicked, save all the info to the `trial`
  # object.
  $('button.next').click ->
    $('input').each (i, el) ->
      trial.info[el.id] = $(el).val()

  # Generate the order of experiements
  experiments = _.shuffle ['s', 'w', 'a', 'f']

  # Always add "natural use" last
  experiments.push('n')

  # Store experiment order.
  trial.experimentOrder = experiments

  # Generate input-orders
  _.each experiments, (e) ->
    trial.experiments[e] = {}
    trial.experiments[e].inputOrder = _.shuffle ['m', 'k', 'b']

  # Setup order for focus test.
  delete trial.experiments['f'].inputOrder
  trial.experiments['f'].order = _.shuffle ['with-fading', 'without-fading']

  # Add the randomize the experiment buttons.
  _.each experiments, (e) ->
    el = $("button#e_#{e}").remove()
    $('#experiments').append(el)
    $(el).click ->
      show $(".view.e_#{e}")

  # Enabled the first experiment.
  $('#experiments button:first-child').removeAttr('disabled')

  # Whever a "previous" button is clicked in the context of an experiment
  # just go back to the list of experiments.
  $('.previous.experiment').click ->
    show $('#experiments').parents('.view'), true

  $('.experiment.done').click ->
    show $('#experiments').parents('.view'), true

  # Re-label all the start buttons.
  $('button.experiment.start:not(.singular):not(.double)').each (i, el) ->
    $el = $(el)
    ex = $el.parents('.view').data('experiment')
    makeLabel = (ex, i) ->
      input = trial.experiments[ex].inputOrder[i]
      label = INPUT_MAP[input]
      return "Perform using <em>#{label}</em>"
    $el.html makeLabel ex, 0
    $el.click ((n, ex) ->
      fn = ->
        msg =
          event: 'experiment start'
          experiment: ex
          input: trial.experiments[ex].inputOrder[n]
        recorder.send msg

        if trial.experiments[ex].inputOrder[n] is 'm'
          postfix = '/?disable-eyejs'
        else
          postfix = '/?enable-eyejs'

        if n < 2
          window.open $el.data('link') + postfix
          $el.html makeLabel ex, ++n
        else
          window.open $el.data('link') + postfix
          $el.html 'You\'re Done!'
          $el.addClass('done')
          $el.off 'click', fn
          $el.click ->
            $("button#e_#{ex}").addClass('done').next().removeAttr('disabled')
            show $('#experiments').parents('.view'), true
      return fn
    )(0, ex)

  $('button.experiment.singular').click ( ->
    fn = ->
      $el = $(this)

      msg =
        event: 'experiment start'
        experiment: 'n'
        input: 'b'
      recorder.send msg

      window.open $el.data('link')
      $el.html 'You\'re Done!'
      $el.addClass('done')
      $el.off 'click', fn
      $el.click ->
        $("button#e_n").addClass('done').next().removeAttr('disabled')
        show $('#experiments').parents('.view'), true
    return fn
  )()

  $('button.experiment.double').click ((n) ->
    fn = ->
      $el = $(this)

      fading = trial.experiments['f'].order[n]

      msg =
        event: 'experiment start'
        experiment: 'f'
        input: 'm'
        fading: fading
      recorder.send msg

      if n < 1
        window.open $el.data('link') + '?' + fading
        $el.html 'One more time...'
        n++
      else
        window.open $el.data('link') + '?' + fading
        $el.html 'You\'re Done!'
        $el.addClass('done')
        $el.off 'click', fn
        $el.click ->
          $("button#e_f").addClass('done').next().removeAttr('disabled')
          show $('#experiments').parents('.view'), true
    return fn
  )(0)

  # Create an interval to see if we're done with all the experiments.
  setInterval ->
    allDone = true
    $('button.experiment.wide.root').each (i, el) ->
      if !$(el).hasClass('done')
        allDone = false
    if allDone
      show $('#done')
      recorder.send event: 'participant end', trial: trial
  , 100
