config = require('singleconfig')

module.exports.show = (req, res) ->
  locals =
    apiKey: config.tokbox.apikey
    hostname: config.hostname
    token: config.demo.tokboxSubscriberToken
    sessionId: config.demo.tokboxSessionId

  res.render('stream/show', locals)
