_       = require 'lodash'
path    = require 'path'
fs      = require 'fs'
program = require 'commander'
async   = require 'async'
moment  = require 'moment'
glob    = require 'glob'


mapExperimentNames = (e) ->
  switch e
    when 'f' then 'Focus'
    when 'w' then 'Wikipedia'
    when 's' then 'Synthetic UI'
    when 'a' then 'Amazon'
    when 'n' then 'Natural Use'



extractEvents = (event, data) ->
  es = []
  for datum in data
    if datum.event and datum.event is event then es.push datum
  es


##
# Takes a logfile filename, reads the file and turns it into a javascript
# array of parsed JSON.
parseLogFile = (filename, done) ->
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
  ], done



displayTrialInfo = (err, data, filename) ->
  if err
    console.error err
    return
  info = extractEvents('participant end', data)
  if info.length is 0
    console.error "
    -------------------------------------------------------------------------
    \nFilename: #{filename}\n
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
      -------------------------------------------------------------------------
      \nFilename: #{filename}\n
      \nName:     #{info.trial.info.firstname} #{info.trial.info.lastname}
      \nEmail:    #{info.trial.info.email}
      \nAge:      #{info.trial.info.age}
      \nDuration: #{trialDuration} minutes
      \nOrder:    #{expOrder.join(', ')}
      \n
      \nSurvey Results:
      \n#{survey}
      "



getLogFiles = (globs, done) ->
  async.map globs, glob, (err, files) ->
    for f, i in files
      files[i] = f[0]
    done(err, files)




cmdInfo = (globs..., options) ->
  getLogFiles globs, (err, files) ->
    for file in files
      parseLogFile file, displayTrialInfo


# cmdInfo = (globs..., options) ->
#   async.map globs,
#
#   for g in globs
#     glob g, null, (err, files) ->
#       parseLogFile file, (err, data) ->
#         if err
#           console.error err
#         else
#           displayTrialInfo(data)




program.version('0.0.1')

program.command('info logfiles...')
  .action(cmdInfo)

program.parse(process.argv)
