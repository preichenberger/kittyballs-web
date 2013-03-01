rootController = require('./controller/root')
rootForm = require('./form/root')
streamController = require('./controller/stream')

module.exports = (app) ->
  app.get('/stream/:id/broadcast', streamController.broadcast)
  app.get('/stream/:id', streamController.show)
  app.get('/stream', streamController.index)

  app.get('/login', rootController.login)
  app.post('/login', rootForm.login, rootController.postLogin)
  app.get('/logout', rootForm.login, rootController.logout)
  app.get('/', rootController.index)
