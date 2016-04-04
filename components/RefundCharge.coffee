# RefundCharge sends a request to refund a charge in part or in full.
#
# SDK:
#   https://github.com/paypal/PayPal-node-SDK/blob/master/samples/sale/refund.js
# Input/output:
#   https://developer.paypal.com/docs/api/#refunds
noflo = require 'noflo'

exports.getComponent = ->
  new noflo.Component
    description: 'refund a sale'
    inPorts:
      id:
        datatype: 'string'
        required: true
        description: 'Charge ID'
      paypal:
        datatype: 'object'
        description: 'Configured Paypal client'
        required: true
      amount:
        datatype: 'string' # double, int
        required: false
        description: 'Amount in the smallest currency units, default is entire charge'
        control: true
      currency:
        datatype: 'string'
        required: false
        description: 'currency'
        control: true
      transactionfee:
        datatype: 'boolean'
        required: false
        description: 'Attempt to refund application fee'
        control: true
    outPorts:
      refund:
        datatype: 'object'
        description: 'Created refund object'
      error:
        datatype: 'object'

    ###
      @see https://developer.paypal.com/webapps/developer/docs/api/#refund-a-sale

      @param refundDetails object
        id: "2MU78835H4515710F"
        "amount": (optional) if left blank, returns the whole ammount
          "currency": "USD"
          "total": "2.34"
    ###
    process: (input, output) ->
      return unless input.has 'id', 'paypal'
      [id, paypal] = input.getData 'id', 'paypal'
      return unless input.ip.type is 'data'

      [amount, currency, transactionfee] = input.getData 'amount', 'currency', 'transactionfee'

      data = {}
      data.transaction_fee = true if transactionfee

      ### @ADAPTER ###
      if amount? and typeof amount isnt 'object' #  and amount > 0
        total = amount
        data.amount =
          total: total
          currency: currency

      paypal.sale.refund id, data, (err, refund) ->
        return output.sendDone err if err
        output.sendDone refund: refund