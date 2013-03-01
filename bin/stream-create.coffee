OpenTok = require('opentok')
Stream = require('../lib/kittyballs-web/model/stream')
User = require('../lib/kittyballs-web/model/user')
async = require('async')
config = require('singleconfig')
mongoose = require('mongoose')
program = require('commander')

program
  .version('0.0.1')
  .option('-e, --email <email>', 'specify an email')
  .option('-n, --name <name>', 'specify a name')
  .parse(process.argv)

GLOBAL.opentokClient = new OpenTok.OpenTokSDK(
  config.tokbox.apikey,
  config.tokbox.apisecret
)

mongoOptions = { db: { safe: true }}
GLOBAL.mongoClient = mongoose.connect(
  config.mongo.url,
  mongoOptions,
  (err, res) ->
    if err
      console.log ('ERROR connecting to mongo:' + err)
)

email = program.email
name = program.name


if !program.email || !program.name
  console.log('ERROR: Email and name are required')
  process.exit(code=1)

async.auto(
  user: (callback) ->
    User.findOne(
      email: email
      callback
    )
  openTokSession: ['user', (callback, results) ->
    if !results.user
      console.log('Could not find user')
      process.exit(code=1)
    
    stream = new Stream(
      _userId: results.user.id
      name: name
    )
 
    GLOBAL.opentokClient.createSession(
      '127.0.0.1',
      { 'p2p.preference' : 'enabled' },
      (result) ->
        if !result
          return callback(new Error('ERROR: Could not create tokbox session'))

        stream.openTokSession = result
        callback(null, stream)
    )
  ]
  openTokTokens: ['openTokSession', (callback, results) ->
    stream = results.openTokSession
    stream.openTokPublisherToken = GLOBAL.opentokClient.generateToken(
      session_id: stream.openTokSession
      role: OpenTok.RoleConstants.PUBLISHER
      connection_data: "userId:#{stream._userId}"
    )
    stream.openTokSubscriberToken = GLOBAL.opentokClient.generateToken(
      session_id: stream.openTokSession
      role: OpenTok.RoleConstants.Subscriber
    )

    callback(null, stream)
  ]
  saveStream: ['openTokTokens', (callback, results) ->
    results.openTokTokens.save(callback)
  ]
  (err, results) ->
    if err
      console.log(err.message)
      process.exit(code=1)

    console.log('Stream added successfully')
    process.exit(code=0)
)
