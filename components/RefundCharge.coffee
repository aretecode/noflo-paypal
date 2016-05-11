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
        description: 'Charge ID'
        required: true
      paypal:
        datatype: 'object'
        description: 'Configured Paypal client'
        required: true
        control: true
      amount:
        datatype: 'string' # double, int
        description: 'Amount in the smallest currency units, default is entire charge'
        required: false
      currency:
        datatype: 'string'
        description: 'currency'
        required: false
      transactionfee:
        datatype: 'boolean'
        description: 'Attempt to refund application fee'
        required: false
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
      [id, paypal, amount, currency, transactionfee] = input.getData 'id', 'paypal', 'amount', 'currency', 'transactionfee'
      return unless input.ip.type is 'data' # id? and paypal?

      data = {}
      data.transaction_fee = true if transactionfee

      ### @ADAPTER ###
      if amount? and typeof amount isnt 'object' #  and amount > 0
        total = amount
        data.amount =
          total: total
          currency: currency

      paypal.sale.refund id, data, (err, refund) ->
        return output.sendDone error: err if err
        # output.sendDone refund: refund
        output.ports.refund.send refund
        output.ports.refund.disconnect()
        output.done()
