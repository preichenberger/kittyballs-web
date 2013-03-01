async = require('async')
mongoose = require('mongoose')

streamSchema = mongoose.Schema(
  _userId: [
    type: mongoose.Schema.Types.ObjectId
    ref: 'User'
  ]
  name:
    type: String
    required: true
  openTokSession:
    type: String
    required: true
  openTokPublisherToken:
    type: String
    required: true
  openTokSubscriberToken:
    type: String
    required: true
)

module.exports = mongoose.model('Stream', streamSchema)
