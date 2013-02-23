config = require('singleconfig')
express = require('express')
lessMiddleware = require('less-middleware')
redis = require('redis')
url = require('url')

app = express()

# Redis
redisURL = url.parse(config.redis.url)
redisAuth = redisURL.auth.split(':')
GLOBAL.redisClient = redis.createClient(
  redisURL.port,
  redisURL.hostname
)
GLOBAL.redisClient.auth(redisAuth[1])

# Views
app.set('view engine', 'jade')
app.set('views', __dirname + '/view')

# Less
bootstrapPath = __dirname + '/../../node_modules/bootstrap'
app.use(lessMiddleware(
  src: __dirname + '/asset/stylesheet'
  paths: [bootstrapPath + '/less']
  dest: __dirname + '/static/css'
  prefix: '/css'
  compress: true
))

# Static
app.use("/css", express.static(__dirname + '/static/css'))
app.use("/images", express.static(__dirname + '/static/images'))
app.use("/js", express.static(__dirname + '/static/js'))

# Middleware
app.use(express.cookieParser())
app.use(express.bodyParser())
app.use(express.logger('short'))
app.use(express.errorHandler())

# Local variables
app.locals.config = config
app.locals.pretty = true

# View variables
app.use((req, res, next) ->
  app.locals.req = req
  app.locals.session = req.session
  app.locals.currentUser = req.user
  next()
)

# Routes
require('./route')(app)

app.listen(config.port)
console.log('Started app on port: ' + config.port)
