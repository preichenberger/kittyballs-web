User = require('../model/user')
config = require('singleconfig')

module.exports.show = (req, res) ->
  User.findSubscriberToken(req.params.id, (err, user) ->
    if err
      res.send(500)

    if !user
      res.send(404)

    locals =
      apiKey: config.tokbox.apikey
      hostname: config.hostname
      token: user.openTokSubscriberToken
      sessionId: user.openTokSession

    res.render('stream/show', locals)
  )

module.exports.broadcast = (req, res) ->
  if !req.user
    return res.redirect('/login')

  locals =
    apiKey: config.tokbox.apikey
    sessionId: req.user.openTokSession
    token: req.user.openTokPublisherToken

  res.render('stream/broadcast', locals)
