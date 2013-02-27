rootController = require('./controller/root')
streamController = require('./controller/stream')

module.exports = (app) ->
  app.get('/stream', streamController.show)
  app.get('/stream/broadcast', streamController.broadcast)

  app.get('/', rootController.index)
