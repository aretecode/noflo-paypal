# https://developer.paypal.com/webapps/developer/docs/api/#delete-a-stored-credit-card
noflo = require 'noflo'

exports.getComponent = ->
  new noflo.Component
    inPorts:
      token:
        datatype: 'string'
        required: true
        description: 'Credit card token'
      paypal:
        datatype: 'object'
        description: 'Configured Paypal client'
        required: true
    outPorts:
      out:
        datatype: 'object'
      error:
        datatype: 'object'
    process: (input, output) ->
      return unless input.has 'token', 'paypal'
      [cardId, paypal] = input.getData 'token', 'paypal'
      return unless input.ip.type is 'data'

      paypal.creditCard.get cardId, (err, credit_card) ->
        return output.sendDone err if err
        output.sendDone out: credit_card
