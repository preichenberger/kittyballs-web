Stream = require('../model/stream')
config = require('singleconfig')

module.exports.index = (req, res) ->
  Stream.find((err, streams) ->
    if err
      res.send(500)

    locals =
      streams: streams
    res.render('stream/index', locals)
  )

module.exports.show = (req, res) ->
  Stream.findOne(
    openTokSession: req.params.id
    (err, stream) ->
      if err
        res.send(500)

      if !stream
        res.send(404)

      locals =
        apiKey: config.tokbox.apikey
        token: stream.openTokSubscriberToken
        sessionId: stream.openTokSession

      res.render('stream/show', locals)
  )

module.exports.broadcast = (req, res) ->
  if !req.user
    return res.redirect('/login')

  Stream.findOne(
    openTokSession: req.params.id
    _userId: req.user._id
    (err, stream) ->
      if err
        res.send(500)

      locals =
        apiKey: config.tokbox.apikey
        sessionId: stream.openTokSession
        token: stream.openTokPublisherToken

      res.render('stream/broadcast', locals)
  )
