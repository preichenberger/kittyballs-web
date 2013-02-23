config = require('singleconfig')

color = () ->
  r = Math.random() * 255
  g = Math.random() * 255
  b = Math.random() * 255
  return [r,g,b]

module.exports.update = (req, res) ->
  if (GLOBAL.sphero)
    switch req.query.command
      when 'roll'
        GLOBAL.sphero.roll(0, .5)
      when 'color'
        rgb = color()
        GLOBAL.sphero.setRGBLED(rgb[0], rgb[1], rgb[2], false)
  res.end()
