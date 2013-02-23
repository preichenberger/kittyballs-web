config = require('singleconfig')
express = require('express')
OpenTok = require('opentok')
redis = require('redis')
roundRobot = require('node-sphero')
url = require('url')

app = express()
server = require('http').createServer(app)
io = require('socket.io').listen(server)

# Sphero
sphero = new roundRobot.Sphero()
sphero.on('connected', (ball) ->
  console.log(ball)
  GLOBAL.sphero = ball
  console.log('Connected to sphero')
)
sphero.connect()

# Redis
redisURL = url.parse(config.redis.url)
redisAuth = redisURL.auth.split(':')
GLOBAL.redisClient = redis.createClient(
  redisURL.port,
  redisURL.hostname
)
GLOBAL.redisClient.auth(redisAuth[1])

# OpenTok
GLOBAL.opentokClient = new OpenTok.OpenTokSDK(config.apikey, config.apisecret)

# Views
app.set('view engine', 'jade')
app.set('views', "#{__dirname}/view")

# Middleware
app.use(express.cookieParser())
app.use(express.bodyParser())
app.use(express.logger('short'))
app.use(express.errorHandler())


# Local variables
app.locals.config = config
app.locals.pretty = true
app.locals.io = io

# Routes
require('./route')(app)

server.listen(config.port)
console.log("Started app on port: #{config.port}")

# Socket io
io = require('socket.io').listen(app)
io.sockets.on('connection', (socket) ->
  socket.emit('connected', {})
  socket.on('command', (data) ->
    console.log(data)
    switch data.action
      when 'roll'
        console.log('rolling')
      when 'back'
        console.log('back')
      else
        console.log('bad key')
  )
)
