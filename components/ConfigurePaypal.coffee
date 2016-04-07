noflo = require 'noflo'
paypal = require 'paypal-rest-sdk'

exports.getComponent = ->
  c = new noflo.Component
    inPorts:
      apikeys:
        datatype: 'object'
        required: true
    outPorts:
      client:
        datatype: 'object'
        description: 'Configured Paypal Client'
      error:
        datatype: 'object'

  c.process (input, output) ->
    return unless input.has 'apikeys'
    apikeys = input.getData 'apikeys'
    return unless input.ip.type is 'data'

    try
      paypal.configure
        'mode': data.mode or 'sandbox' # sandbox or live
        'client_id': data.id
        'client_secret': data.secret
      output.sendDone client: paypal
    catch e
      output.sendDone error: e
