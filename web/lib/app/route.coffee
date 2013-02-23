rootController = require('./controller/root')
streamController = require('./controller/stream')

module.exports = (app) ->
  app.get('/stream/:id', streamController.show)

  app.get('/', rootController.index)
