_       = require 'lodash'
path    = require 'path'
fs      = require 'fs'
program = require 'commander'
async   = require 'async'
moment  = require 'moment'
mathjs  = require 'mathjs'


mapExperimentNames = (e) ->
  switch e
    when 'f' then 'Focus #1'
    when 'ff' then 'Focus w/ Fading'
    when 'fw' then 'Focus w/o Fading'
    when 'w' then 'Wikipedia'
    when 's' then 'Synthetic UI'
    when 'a' then 'Amazon'
    when 'n' then 'Natural Use'


mapInputNames = (e) ->
  switch e
    when 'b' then 'Blinks'
    when 'k' then 'Keypress'
    when 'm' then 'Mouse'


##
# Extracts the specified event from the passed data.
extractEvent = (event, data) ->
  events = []
  data = _.sortBy data, ((e) -> e.timestamp)
  switch event
    when 'mouseclick' then events = extractMouseClicks(data)
    when 'experiment' then events = extractExperiments(data)
    else
      for datum in data
        if datum.event and datum.event is event then events.push datum
  events


##
# Extracts the specified events (using the passed CLI options) and returns
# an array of the matching events.
extractEvents = (data, options) ->
  events = []

  union = (arr) -> events = events.concat arr

  if options.mouseMove then union extractEvent('mousemove', data)
  if options.mouseDown then union extractEvent('mousedown', data)
  if options.mouseUp then union extractEvent('mouseup', data)
  if options.mouseClick then union extractEvent('mouseclick', data)
  if options.gaze then union extractEvent('gaze', data)
  if options.blink then union extractEvent('blink', data)
  if options.fixation then union extractEvent('fixation', data)
  if options.fixationEnd then union extractEvent('fixationend', data)
  if options.load then union extractEvent('load', data)
  if options.unload then union extractEvent('unload', data)
  if options.experiment then union extractEvent('experiment', data)

  _.sortBy events, ((e) -> e.timestamp)


##
# Extracts mouse-click events from the passed data using the logged mouse-down
# and mouse-up events.
extractMouseClicks = (data) ->
  es = []
  downElement = null
  for datum in data
    if datum.event
      if datum.event is 'mousedown'
        downElement = datum.element
      if datum.event is 'mouseup'
        if datum.element is downElement
          es.push datum
  es


##
# Extracts mouse-click events from the passed data using the logged mouse-down
# and mouse-up events.
extractExperiments = (data) ->
  es = []
  downElement = null
  for datum in data
    if datum.event and datum.event.match /experiment/
      es.push datum
  es


##
# Takes a logfile filename, reads the file and turns it into a javascript
# array of parsed JSON.
parseLogFile = (filename, done, options) ->
  fpath = path.resolve process.cwd(), filename
  async.waterfall [
    (cb) ->
      fs.readFile(fpath, {encoding: 'utf8'}, cb)
    (contents, cb) ->
      data = contents.split '\n'
      for entry, i in data
        if entry.length is 0
          continue
        try
          data[i] = JSON.parse entry
        catch e
          cb(e)
      for datum, i in data
        if datum is ''
          data.splice i, 1
      cb(null, data, filename)
  ], (err, data, filename) ->
    if err
      console.error err
      process.exit 1
    else
      done.call null, data, filename, options


collectExperimentTimes = (data, filename, options) ->
  times = {}
  events = extractEvents data, {unload: true, experiment: true}
  experimentStarts = {}
  experimentUnloads = {}
  currExp = null
  currInput = null

  for e in events
    if e.event is 'experiment start'
      currExp = e.experiment
      currInput = e.input

      if currExp is 'f' and e.fading is 'with-fading'
        currExp = 'ff'

      if currExp is 'f' and e.fading is 'without-fading'
        currExp = 'fw'

      experimentUnloads[currExp] ?= {}
      experimentStarts[currExp] ?= {}
      experimentUnloads[currExp][currInput] = []
      experimentStarts[currExp][currInput] = e.timestamp

    else if currExp
      experimentUnloads[currExp][currInput].push e

  for e of experimentUnloads
    for input, unloads of experimentUnloads[e]
      if unloads.length > 0
        t = unloads[unloads.length - 1].timestamp
      else
        t = Infinity
      times[e] ?= {}
      times[e][input] =
        experiment: e
        input: input
        start: experimentStarts[e][input]
        end: t
        duration: t - experimentStarts[e][input]

  return times


displayHeader = (filename) ->
  console.log "
    \n-------------------------------------------------------------------------
    \nFilename: #{filename}\n"


##
# Displays trial and survey info for the passed trial logs.
displayTrialInfo = (data, filename) ->
  info = extractEvent('participant end', data)
  displayHeader filename
  if info.length is 0
    console.error "
    \nNo participant information found.\n
    "
  else
    info = info[0]
    trialDuration = moment.duration(info.timestamp - info.trial.start).minutes()
    expOrder = info.trial.experimentOrder.map mapExperimentNames
    survey = ''
    for question, answer of info.trial.survey
      survey += "#{question} – \"#{answer}\"\n"
    console.log "
      \nName:     #{info.trial.info.firstname} #{info.trial.info.lastname}
      \nEmail:    #{info.trial.info.email}
      \nAge:      #{info.trial.info.age}
      \nDuration: #{trialDuration} minutes
      \nOrder:    #{expOrder.join(', ')}
      \n
      \nSurvey Results:
      \n#{survey}
      "


##
# Displays extracted event data.
displayExtractedEvents = (data, filename, options) ->
  events = extractEvents data, options

  if options.json
    for e, i in events
      events[i] = JSON.stringify(e)

  else if options.csv
    if events.length > 0
      labels = []
      for k, v of events[0]
        labels.push k
      console.log labels.join ','
      for e, i in events
        evt = []
        for k, v of events[i]
          evt.push v
        events[i] = evt.join ','

  if options.count
    console.log events.length
  else
    console.log events.join '\n'



displayExperimentInfo = (data, filename, options) ->
  times = collectExperimentTimes data, filename, options

  displayHeader filename

  for e of times
    for input,v of times[e]
      console.log mapExperimentNames(e), mapInputNames(v.input), moment.duration(v.duration).asSeconds()



info = (files, options) ->
  for file in files
    if options.experiment
      parseLogFile file, displayExperimentInfo, options
    else
      parseLogFile file, displayTrialInfo, options



extract = (files, options) ->
  for file in files
    parseLogFile file, displayExtractedEvents, options



analyzeExperimentTimes = (files, options) ->
  times = []

  fn = (file, done) ->
    async.waterfall [
      (cb) ->
        parseCb = ->
          cb(null, arguments...)
        parseLogFile file, parseCb, options
      (data, filename, options, cb) ->
        times.push collectExperimentTimes data, filename, options
        cb(null)
    ], done

  async.each files, fn, (err) ->
    if err
      console.error 'Error analyzing times:', err
      process.exit()

    acc = {}
    mean = {}
    median = {}

    for t in times
      for exp of t
        for input, v of t[exp]
          acc[exp] ?= {}
          acc[exp][input] ?= []
          if v.duration < Infinity then acc[exp][input].push v.duration

    for exp of acc
      for input, duration of acc[exp]
        mean[exp] ?= {}
        median[exp] ?= {}
        mean[exp][input] = Math.round mathjs.mean(acc[exp][input])
        median[exp][input] = Math.round mathjs.median(acc[exp][input])

    console.log "\n\n---Mean Experiment Durations---"

    for exp of mean
      for input, duration of mean[exp]
        console.log mapExperimentNames(exp), mapInputNames(input), duration

    console.log "\n\n---Median Experiment Durations---"

    for exp of median
      for input, duration of median[exp]
        console.log mapExperimentNames(exp), mapInputNames(input), duration



analyze = (files, options) ->
  analyzeExperimentTimes files, options



parseArgs = (files..., options) ->

  if options.info
    info files, options

  if options.display
    extract files, options

  if options.analyze
    analyze files, options



program
  .version('0.0.1')
  .usage('<log> [logs...]')
  .option('-a, --analyze', 'perform log analysis')
  .option('-i, --info', 'ouput formatted information')
  .option('-D, --display', 'extract and display event information')
  .option('-x, --experiment', 'include experiment events')
  .option('-l, --load', 'include load events')
  .option('-L, --unload', 'include unload events')
  .option('-m, --mouse-move', 'include mouse move events')
  .option('-d, --mouse-down', 'include mouse down events')
  .option('-u, --mouse-up', 'include mouse up events')
  .option('-c, --mouse-click', 'include mouse click events')
  .option('-g, --gaze', 'include gaze events')
  .option('-b, --blink', 'include blink events')
  .option('-f, --fixation', 'include fixation events')
  .option('-F, --fixation-end', 'include fixation-end events')
  .option('-C, --count', 'prints the count of the cooresponding events')
  .option('-j, --json', 'print output as JSON')
  .option('-s, --csv', 'print output as CSV')
  .action(parseArgs)

program.parse(process.argv)
