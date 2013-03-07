form = require('express-form')
field = form.field

module.exports.login = (req, res, next) ->
  emailField = field('email')
    .trim()
    .isEmail('A valid email is required')
    .required('A valid email is required')
    .notEmpty('A valid email is required')

  passwordField = field('password')
    .trim()
    .isAlphanumeric('Password must be alphanumeric')
    .minLength(6, 'Password must be at least 6 characters')
    .required('A valid password is required')
    .notEmpty('A valid password is required')

  return form(
    emailField,
    passwordField,
  )(req, res, next)
