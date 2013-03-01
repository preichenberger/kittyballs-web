config = require('singleconfig')
rootForm = require('../form/root')
User = require('../model/user')

module.exports.index = (req, res) ->
  if req.user
    return res.redirect('/stream')

  res.render('root/index')

module.exports.login = (req, res) ->
  res.render('root/login',
    form: {}
  )

module.exports.logout = (req, res) ->
  req.logout()
  res.redirect('/')

module.exports.postLogin = (req, res, next) ->
  renderError = (err) ->
    if err
      req.form.errors.push(err.message)
    else if !req.form.errors
      req.form.errors.push('There was an error with your login')

    res.render('root/login',
      form: req.form
    )

  if !req.form.isValid
    return renderError()

  User.findAuthenticatedUser(req.form.email, req.form.password, (err, user) ->
    if err
      return renderError()
    if !user
      return renderError(new Error('Invalid email or password'))

    req.login(user, (err) ->
      if err
        return renderError()

      return res.redirect('/')
    )
  )
