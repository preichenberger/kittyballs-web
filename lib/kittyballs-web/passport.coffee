passport = require('passport')
LocalStrategy = require('passport-local').Strategy

passport.use(new LocalStrategy(
  usernameField: 'email',
  passwordField: 'password',
  (email, password, done) ->
    User.findOne({ email: email }, (err, user) ->
      if err
        return done(err)

      if !user
        return done(null, false, { message: 'Incorrect email or password.' })
      if !user.validPassword(password)
        return done(null, false, { message: 'Incorrect email or password.' })

      return done(null, user)
    )
))

passport.serializeUser((user, done) ->
  done(null, user)
)

passport.deserializeUser((user, done) ->
  done(null, user)
)

module.exports = passport
