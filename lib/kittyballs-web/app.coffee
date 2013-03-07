config = require('singleconfig')
express = require('express')
lessMiddleware = require('less-middleware')
mongoose = require('mongoose')
OpenTok = require('opentok')
passport = require('./passport')
redis = require('redis')
RedisStore = require('connect-redis')(express)
socketioServer = require('./socketio')
url = require('url')

# Servers
app = express()
server = require('http').createServer(app)
io = require('socket.io').listen(server)

# Redis
redisURL = url.parse(config.redis.url)
redisAuth = redisURL.auth.split(':')
GLOBAL.redisClient = redis.createClient(
  redisURL.port,
  redisURL.hostname
)
GLOBAL.redisClient.auth(redisAuth[1])

# Mongo
mongoOptions = { db: { safe: true }}
GLOBAL.mongoClient = mongoose.connect(
  config.mongo.url,
  mongoOptions,
  (err, res) ->
    if err
      console.log ('ERROR connecting to mongo:' + err)
)

# OpenTok
GLOBAL.opentokClient = new OpenTok.OpenTokSDK(
  config.tokbox.apikey,
  config.tokbox.apisecret
)

# Passport
GLOBAL.passport = passport

# Views
app.set('view engine', 'jade')
app.set('views', "#{__dirname}/view")

# Less
bootstrapPath = "#{__dirname}/../../node_modules/bootstrap"
app.use(lessMiddleware(
  src: "#{__dirname}/asset/stylesheet"
  paths: ["#{bootstrapPath}/less"]
  dest: "#{__dirname}/static/css"
  prefix: '/css'
  compress: true
))

# Static
app.use("/css", express.static("#{__dirname}/static/css"))
app.use("/images", express.static("#{__dirname}/static/images"))
app.use("/js", express.static("#{__dirname}/static/js"))

# Middleware
app.use(express.cookieParser())
app.use(express.bodyParser())
app.use(express.logger('short'))
app.use(express.errorHandler())
app.use(express.session(
  store: new RedisStore(
    client: GLOBAL.redisClient
  )
  secret: config.session.secret
))
app.use(GLOBAL.passport.initialize())
app.use(GLOBAL.passport.session())


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

server.listen(config.port)
console.log("Started app on port: #{config.port}")

# Socket io
io.configure(() ->
  SocketRedisStore = require('socket.io/lib/stores/redis')
   
  io.set('transports', ['xhr-polling'])
  io.set('polling duration', 10)
  io.set('log level', 1)
  io.set('close timeout', 10)
  io.set('store', new SocketRedisStore(
    redis: redis,
    redisPub: GLOBAL.redisClient,
    redisSub: GLOBAL.redisClient,
    redisClient: GLOBAL.redisClient,
  ))
)

io.sockets.on('connection', (socket) ->
  socket.on('message', (data) ->
    socketioServer.handleMessage(io, socket, data)
  )
)
