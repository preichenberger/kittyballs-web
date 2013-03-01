async = require('async')
bcrypt = require('bcrypt')
mongoose = require('mongoose')

userSchema = mongoose.Schema(
  email:
    type: String
    required: true
    index:
      unique: true
      dropDups: true
  password:
    type: String
    required: true
  streams: [
    type: mongoose.Schema.Types.ObjectId
    ref: 'Stream'
  ]
)

userSchema.methods.setPassword = (password, callback) ->
  self = this
  bcrypt.hash(password, 10, (err, hash) ->
    self.password = hash
    callback(err, self)
  )

userSchema.methods.checkPassword = (password) ->
  return bcrypt.compareSync(password, this.password)

userSchema.statics.findAuthenticatedUser = (email, password, callback) ->
  User = this
  async.auto(
    findUser: (subCallback) ->
      User.findOne(
        { email: email },
        subCallback
      )
    authenticatedUser: ['findUser', (subCallback, results) ->
      if !results.findUser || !results.findUser.checkPassword(password)
        subCallback()
      subCallback(null, results.findUser)
    ]

    (err, results) ->
      if err
        return callback(err)

      return callback(null, results.authenticatedUser)
  )

module.exports = mongoose.model('User', userSchema)
