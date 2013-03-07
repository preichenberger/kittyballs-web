OpenTok = require('opentok')
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
        return res.send(500)

      if !stream
        return res.send(404)

      subscriberToken = GLOBAL.opentokClient.generateToken(
        session_id: stream.openTokSession
        role: OpenTok.RoleConstants.SUBSCRIBER
      )

      locals =
        apiKey: config.tokbox.apikey
        token: subscriberToken
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
        return res.send(500)
      
      publisherToken = GLOBAL.opentokClient.generateToken(
        session_id: stream.openTokSession
        role: OpenTok.RoleConstants.PUBLISHER
        connection_data: "userId:#{stream._userId}"
      )

      locals =
        apiKey: config.tokbox.apikey
        sessionId: stream.openTokSession
        token: publisherToken

      res.render('stream/broadcast', locals)
  )
