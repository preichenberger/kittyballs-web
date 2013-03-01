Stream = require('./model/stream')
async = require('async')

module.exports.handleMessage = (io, socket, data) ->
  console.log(data)
  if data.action == 'join'
    if !data.role
      return

    if data.role == 'subscriber'
      if data.room
        clients = io.sockets.clients(data.room)
      else
        return

      if clients.length != 1
        return
      
      # Join room
      socket.join(data.room)
      clientNum = io.sockets.clients(data.room).length
      console.log("A subscriber joined: #{data.room}, #{clientNum}")
      return

    if data.role == 'publisher'
      if !data.publisherToken
        return

      # Verify publisher
      Stream.findOne(
        openTokPublisherToken: data.publisherToken
        (err, stream) ->
          if (err)
            console.error(err.message)
            return
          
          if stream
            socket.join(stream.openTokSession)
            clientNum = io.sockets.clients(stream.openTokSession).length
            console.log(
              "A publisher joined: #{stream.openTokSession}, #{clientNum}"
            )

          return
      )

  else
    if !data.room
      return
    
    rooms = io.sockets.manager.roomClients[socket.id]
    if !rooms["/#{data.room}"]
      return
   
    io.sockets.in(data.room).emit('message', data)
