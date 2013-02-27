config = require('singleconfig')

module.exports.show = (req, res) ->
  locals =
    apiKey: config.tokbox.apikey
    hostname: config.hostname
    token: config.demo.tokboxSubscriberToken
    sessionId: config.demo.tokboxSessionId

  res.render('stream/show', locals)

module.exports.broadcast = (req, res) ->
  locals =
    apiKey: config.tokbox.apikey
    sessionId: config.demo.tokboxSessionId
    token: config.demo.tokboxPublisherToken
    
  res.render('stream/broadcast', locals)
