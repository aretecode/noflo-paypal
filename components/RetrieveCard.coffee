# https://developer.paypal.com/webapps/developer/docs/api/#delete-a-stored-credit-card
noflo = require 'noflo'

exports.getComponent = ->
  new noflo.Component
    inPorts:
      token:
        datatype: 'string'
        description: 'Credit card token'
        required: true
      paypal:
        datatype: 'object'
        description: 'Configured Paypal client'
        required: true
        control: true
    outPorts:
      out:
        datatype: 'object'
      error:
        datatype: 'object'
    process: (input, output) ->
      return unless input.has 'token', 'paypal', (ip) -> ip.type is 'data'
      [cardId, paypal] = input.getData 'token', 'paypal'

      paypal.creditCard.get cardId, (err, credit_card) ->
        return output.sendDone err if err
        output.sendDone out: credit_card
