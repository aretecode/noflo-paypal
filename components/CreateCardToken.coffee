# CreateCardToken c creates a new credit card token.
#
# Input/output: https://developer.paypal.com/docs/api/#vault
# https://github.com/paypal/PayPal-node-SDK/blob/master/samples/credit_card/create.js
noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
    inPorts:
      card:
        datatype: 'object'
        description: 'Credit card details'
        required: true
      paypal:
        datatype: 'object'
        description: 'Configured Paypal client'
        required: true
    outPorts:
      token:
        datatype: 'object'
        description: 'New token'
      error:
        datatype: 'object'

  c.checkRequired = (card, callback) ->
    errors = []
    unless card.number
      errors.push noflo.helpers.CustomError "Missing card number",
        kind: 'card_error'
        code: 'invalid_number'
        param: 'number'
    unless card.exp_month or card.exp_month < 1 or card.exp_month > 12
      errors.push noflo.helpers.CustomError "Missing or invalid expiration month",
        kind: 'card_error'
        code: 'invalid_expiry_month'
        param: 'exp_month'
    unless card.exp_year or card.exp_year < 0 or card.exp_year > 2100
      errors.push noflo.helpers.CustomError "Missing or invalid expiration year",
        kind: 'card_error'
        code: 'invalid_expiry_year'
        param: 'exp_year'
    errors

  c.process (input, output) ->
    return unless input.has 'card', 'paypal'
    [card, paypal] = input.getData 'card', 'paypal'
    return unless input.ip.type is 'data'

    # Validate inputs
    errors = c.checkRequired card
    if errors.length > 0
      return output.sendDone errors

    # Create Paypal token
    data =
      card: card
    savedCard =
      'type': 'visa'
      'number': '4417119669820331'
      'expire_month': '11'
      'expire_year': '2019'
      'cvv2': '123'
      'first_name': 'Joe'
      'last_name': 'Shopper'

    paypal.creditCard.create savedCard, (err, credit_card) ->
      return output.sendDone err if err
      output.sendDone token: credit_card
