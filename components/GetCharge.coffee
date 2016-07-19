# GetCharge component fetches a charge object by ID.
#
# https://developer.paypal.com/docs/api/#look-up-a-payment-resource
noflo = require 'noflo'

exports.getComponent = ->
  new noflo.Component
    inPorts:
      id:
        datatype: 'string'
      paypal:
        datatype: 'object'
        description: 'Configured Paypal client'
        required: true
        control: true
    outPorts:
      charge:
        datatype: 'object'
      error:
        datatype: 'object'
    process: (input, output) ->
      return unless input.has 'id', (ip) -> ip.type is 'data'
      [id, paypal] = input.getData 'id', 'paypal'

      paypal.payment.get id, (err, charge) ->
        return output.sendDone err if err
        output.sendDone charge: charge
