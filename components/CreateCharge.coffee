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

    ###
      'amount':
        'currency': 'USD'
        'total': '4.54'
      'is_final_capture': true
    ###
    if payload.currency?
      payload.currency = payload.currency.toUpperCase()

    ### @ADAPTER ###
    if payload.amount? and typeof payload.amount isnt 'object'
      total = payload.amount
      payload.amount =
        total: total
        currency: payload.currency
      # delete payload.currency

    # Validate inputs
    errors = c.checkRequired payload
    if errors.length > 0
      return output.sendDone errors

    ###
    transactions =
      [ {
        'item_list': 'items': [ {
          'name': 'item'
          'sku': 'item'
          'price': '1.00'
          'currency': 'USD'
          'quantity': 1
        } ]
        'amount':
          'currency': 'USD'
          'total': '1.00'
        'description': 'This is the payment description.'
      } ]
    ###
    transactions =
      [ {
        'amount': payload.amount
        'description': 'This is the payment transaction description.' # @TODO
        #'custom': 'EBAY_EMS_90048630024435' # @TODO
        #'invoice_number': chargeData.invoice # @TODO
        #'payment_options': 'allowed_payment_method': 'INSTANT_FUNDING_SOURCE'
        #'soft_descriptor': 'ECHI5786786'
      } ]

    # Authorize capture
    # itemslist
    # details
    create_payment_json =
      'intent': payload.intent or 'sale'
      'payer': payload.payer
      'transactions': transactions
      #'redirect_urls':
      #  'return_url': 'http://www.return.com'
      #  'cancel_url': 'http://www.cancel.com'

    if payload.payer.payment_method is 'paypal'
      console.log 'IS PAYPAL______'
      create_payment_json =
        'intent': 'sale'
        'payer': 'payment_method': 'paypal'
        'redirect_urls':
          'return_url': 'http://return.url'
          'cancel_url': 'http://cancel.url'
        'transactions': [ {
          'item_list': 'items': [ {
            'name': 'item'
            'sku': 'item'
            'price': '1.00'
            'currency': 'USD'
            'quantity': 1
          } ]
          'amount':
            'currency': 'USD'
            'total': '1.00'
          'description': 'This is the payment description.'
        } ]

    # console.log JSON.stringify(create_payment_json)
    paypal.payment.create create_payment_json, (err, payment) ->
      return output.sendDone err if err
      output.sendDone charge: payment
