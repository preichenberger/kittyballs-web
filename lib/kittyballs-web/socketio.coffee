Stream = require('./model/stream')
async = require('async')

toKey = (values) ->
  return values.join(':')

authPublisher = (broadcastKey, callback) ->
  Stream.findOne(
    broadcastKey: broadcastKey
    (err, stream) ->
      return callback(err, stream)
  )

addSubscriberToRoom = (room, socket, io) ->
  key = toKey(['room', room, 'publisher'])
  async.auto(
    hasPublisher: (callback) ->
      GLOBAL.redisClient.get(key, callback)
    (err, results) ->
      if err
        console.error(err.message)
        return

      clientNum = io.sockets.clients(room).length

      if results.hasPublisher and clientNum <= 1
        socket.join(room)
        console.log("A subscriber joined: #{room}")
  )

addPublisherToRoom = (broadcastKey, socket, io) ->
  authPublisher(broadcastKey, (err, stream) ->
    if err
      console.error(err.message)
      return

    room = stream.openTokSession
    key = toKey(['room', room, 'publisher'])
    socket.join(room)

    GLOBAL.redisClient.setex(key, 60, true)
    console.log("A publisher joined: #{room}")
  )

pingPublisher = (broadcastKey, socket, io) ->
  authPublisher(broadcastKey, (err, stream) ->
    if err
      console.error(err.message)
      return

    room = stream.openTokSession
    key = toKey(['room', room, 'publisher'])
    GLOBAL.redisClient.setex(key, 60, true)

    socket.emit('message',
      action: 'pong'
    )
  )

module.exports.handleMessage = (io, socket, data) ->
  if data.action == 'join'
    if data.role == 'subscriber'
      return addSubscriberToRoom(data.room, socket, io)
     
    if data.role == 'publisher'
      return addPublisherToRoom(data.broadcastKey, socket, io)
  else if data.action == 'ping'
    return pingPublisher(data.broadcastKey, socket, io)
  else
    if !data.room
      return
    
    rooms = io.sockets.manager.roomClients[socket.id]
    if !rooms["/#{data.room}"]
      return
   
    io.sockets.in(data.room).emit('message', data)
