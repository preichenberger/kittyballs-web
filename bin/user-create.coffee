User = require('../lib/kittyballs-web/model/user')
async = require('async')
config = require('singleconfig')
mongoose = require('mongoose')
program = require('commander')

program
  .version('0.0.1')
  .option('-e, --email <email>', 'specify an email')
  .parse(process.argv)

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
  console.log('ERROR: Email is required')
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
  saveUser: ['userPassword', (callback, results) ->
    results.userPassword.save(callback)
  ]
  (err, results) ->
    if err
      console.log(err.message)
      process.exit(code=1)

    console.log('User added successfully')
    process.exit(code=0)
)
