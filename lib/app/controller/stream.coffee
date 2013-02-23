config = require('singleconfig')

module.exports.show = (req, res) ->
  locals =
    apiKey: config.tokbox.apikey
    sessionId: config.demo.tokboxSessionId
    token: config.demo.tokboxSubscriberToken

  res.render('stream/show', locals)
