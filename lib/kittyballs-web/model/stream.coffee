async = require('async')
mongoose = require('mongoose')
uuid = require('uuid')

streamSchema = mongoose.Schema(
  _userId: [
    type: mongoose.Schema.Types.ObjectId
    ref: 'User'
  ]
  name:
    type: String
    required: true
  broadcastKey:
    type: String
    required: true
    default: uuid.v4()
  openTokSession:
    type: String
    required: true
)

module.exports = mongoose.model('Stream', streamSchema)
