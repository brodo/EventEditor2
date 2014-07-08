parser = require('./JSEPLParser/epl2.js')
module.exports = (epl) ->
  console.log(parser.parse(epl))