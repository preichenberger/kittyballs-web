rootController = require('./controller/root')
streamController = require('./controller/stream')

module.exports = (app) ->
  app.get('/stream/:id', streamController.show)

  app.get('/broadcast', rootController.broadcast)
  app.get('/', rootController.index)
