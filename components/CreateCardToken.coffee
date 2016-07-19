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
        control: true
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
    unless card.expire_month or card.expire_month < 1 or card.expire_month > 12
      errors.push noflo.helpers.CustomError "Missing or invalid expiration month",
        kind: 'card_error'
        code: 'invalid_expiry_month'
        param: 'exp_month'
    unless card.expire_year or card.expire_year < 0 or card.expire_year > 2100
      errors.push noflo.helpers.CustomError "Missing or invalid expiration year",
        kind: 'card_error'
        code: 'invalid_expiry_year'
        param: 'exp_year'
    errors

  c.process (input, output) ->
    return unless input.has 'card', 'paypal', (ip) -> ip.type is 'data'

    [card, paypal] = input.getData 'card', 'paypal'

    # Validate inputs
    errors = c.checkRequired card
    if errors.length > 0
      return output.sendDone errors

    paypal.creditCard.create card, (err, credit_card) ->
      return output.sendDone err if err
      output.sendDone token: credit_card
