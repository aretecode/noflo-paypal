# https://developer.paypal.com/docs/api/#payments
# https://github.com/paypal/PayPal-node-SDK/tree/master/samples/payout
noflo = require 'noflo'

exports.getComponent = ->
  new noflo.Component
    description: 'send payout'
    icon: 'money'
    inPorts:
      data:
        datatype: 'string'
      paypal:
        datatype: 'object'
        description: 'Configured Paypal client'
        required: true
    outPorts:
      out:
        datatype: 'integer'
      error:
        datatype: 'object'
    process: (input, output) ->
      return unless input.has 'data'
      [data, paypal] = input.getData 'data', 'paypal'
      return unless input.ip.type is 'data'

      paypal.payout.create data, (err, payout) ->
        return output.sendDone err if err
        output.sendDone out: payout
