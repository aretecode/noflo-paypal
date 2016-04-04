# https://developer.paypal.com/webapps/developer/docs/api/#delete-a-stored-credit-card
noflo = require 'noflo'

exports.getComponent = ->
  new noflo.Component
    inPorts:
      card:
        datatype: 'object'
        required: true
        description: 'Credit card details'
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
      return unless input.has 'card', 'paypal'
      [cardId, paypal] = input.getData 'card', 'paypal'
      return unless input.ip.type is 'data'

      paypal.creditCard.del cardId, (err, credit_card) ->
        return output.sendDone err if err
        output.sendDone out: credit_card
