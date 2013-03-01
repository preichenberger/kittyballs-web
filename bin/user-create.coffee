OpenTok = require('opentok')
User = require('../lib/kittyballs-web/model/user')
async = require('async')
config = require('singleconfig')
mongoose = require('mongoose')
program = require('commander')

program
  .version('0.0.1')
  .option('-e, --email <email>', 'specify an email')
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
password = ''

if !program.email
  console.log('ERROR: Email and password required')
  process.exit(code=1)

async.auto(
  password: (callback) ->
    program.password('Enter password: ', (input) ->
      callback(null, input)
    )
  userPassword: ['password', (callback, results) ->
    user = new User(
      email: program.email
    )
    user.setPassword(results.password, callback)
  ]
  openTokSession: ['userPassword', (callback, results) ->
    GLOBAL.opentokClient.createSession(
      '127.0.0.1',
      { 'p2p.preference' : 'enabled' },
      (result) ->
        if !result
          return callback(new Error('Could not create tokbox session'))

        results.userPassword.openTokSession = result
        callback(null, results.userPassword)
    )
  ]
  openTokTokens: ['openTokSession', (callback, results) ->
    user = results.openTokSession
    user.openTokPublisherToken = GLOBAL.opentokClient.generateToken(
      session_id: user.openTokSession
      role: OpenTok.RoleConstants.PUBLISHER
      connection_data: "userId:#{user.id}"
    )
    user.openTokSubscriberToken = GLOBAL.opentokClient.generateToken(
      session_id: user.openTokSession
      role: OpenTok.RoleConstants.Subscriber
    )

    callback(null, user)
  ]
  saveUser: ['openTokTokens', (callback, results) ->
    results.openTokSession.save(callback)
  ]
  (err, results) ->
    if err
      console.log(err.message)
      process.exit(code=1)

    console.log('User added successfully')
    process.exit(code=0)
)
