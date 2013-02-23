rootController = require('./controller/root')
spheroController = require('./controller/sphero')


module.exports = (app) ->
  app.all('/sphero', spheroController.update)

  app.get('/broadcast', rootController.broadcast)
  app.get('/', rootController.index)
