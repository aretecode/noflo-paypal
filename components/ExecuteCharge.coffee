# CreateCharge c creates a new charge.
# https://github.com/svetly/noflo-stripe/blob/master/cs/CreateCharge.coffee
# https://github.com/paypal/PayPal-node-SDK/blob/master/samples/configuration/multiple_config.js
# https://github.com/paypal/PayPal-node-SDK/blob/master/samples/payment/create_with_credit_card.js
# https://github.com/paypal/PayPal-node-SDK/blob/master/samples/payment/execute.js
noflo = require 'noflo'

exports.getComponent = ->
  new noflo.Component
    inPorts:
      data: # chargeid
        datatype: 'object'
        required: true
      paypal:
        datatype: 'object'
        description: 'Configured Paypal client'
        required: true
    outPorts:
      charge:
        datatype: 'object'
      error:
        datatype: 'object'
    description: 'execute a charge created in a previous step'
    icon: 'money'
    process: (input, output) ->
      return unless input.has 'data', 'paypal'
      [data, paypal] = input.getData 'data', 'paypal'
      return unless input.ip.type is 'data'

      # @TODO: change
      execute_payment_json = {}
      execute_payment_json.payer_id = data.payerid # 'Appended to redirect url'
      # 'transactions': data.transactions
      # paymentId = 'PAYMENT id created in previous step'

      paypal.payment.execute data.paymentid, execute_payment_json, (err, payment) ->
        return output.sendDone err if err
        output.sendDone charge: payment
