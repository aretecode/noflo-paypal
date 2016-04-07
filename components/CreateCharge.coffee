# CreateCharge c creates a new charge.
# https://github.com/svetly/noflo-stripe/blob/master/cs/CreateCharge.coffee
# https://github.com/paypal/PayPal-node-SDK/blob/71dcd3a5e2e288e2990b75a54673fb67c1d6855d/samples/configuration/multiple_config.js
# https://github.com/paypal/PayPal-node-SDK/blob/master/samples/payment/create_with_credit_card.js
# https://github.com/paypal/PayPal-node-SDK/tree/master/samples/payment
# https://github.com/paypal/PayPal-node-SDK/blob/master/samples/payment/execute.js
# https://developer.paypal.com/docs/api/#payments
noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
    inPorts:
      data: # charge
        datatype: 'object'
        required: true
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
    description: 'create a charge to be executed later'
    icon: 'money'

  c.checkRequired = (chargeData, callback) ->
    errors = []
    unless chargeData.amount
      errors.push noflo.helpers.CustomError "Missing amount",
        kind: 'internal_error'
        code: 'missing_charge_amount'
        param: 'amount'
    unless chargeData.currency or chargeData.amount.currency
      errors.push noflo.helpers.CustomError "Missing currency",
        kind: 'internal_error'
        code: 'missing_charge_currency'
        param: 'currency'
    errors

  c.process (input, output) ->
    return unless input.has 'data', 'paypal'
    [payload, paypal] = input.getData 'data', 'paypal'
    return unless input.ip.type is 'data'

    if payload.currency?
      payload.currency = payload.currency.toUpperCase()

    amount =
      currency: payload.currency # 'USD'
      total: payload.amount # '1.00'

    # Validate inputs
    errors = c.checkRequired payload
    if errors.length > 0
      return output.sendDone errors

    # map some properties?-
    json =
      intent: 'sale'
      payer: payload.payer

    json.redirect_urls = payload.redirect_urls if payload.redirect_urls?
    json.is_final_capture = payload.is_final_capture if payload.is_final_capture? # boolean

    # USE AMOUNT IF THERE ARE NO TRANSACTIONS
    unless payload.transactions
      json.transactions =
        [ {
          amount: amount
          description: 'This is the payment transaction description.' # @TODO
          #custom: 'EBAY_EMS_90048630024435' # @TODO
          #invoice_number: chargeData.invoice # @TODO
          #payment_options: 'allowed_payment_method': 'INSTANT_FUNDING_SOURCE'
          #soft_descriptor: 'ECHI5786786'
        } ]
    else
      json.transactions = [{}]

    # meaning there is only one transaction, do a test with multiple
    if payload.items and payload.payer.payment_method is 'paypal'
      json.transactions[0].description = payload.description or 'This is the payment description.'
      json.transactions[0].amount = amount
      json.transactions[0].item_list =
        items: [payload.items]

    # console.log JSON.stringify(payload)
    paypal.payment.create json, (err, payment) ->
      return output.sendDone err if err
      output.sendDone charge: payment
