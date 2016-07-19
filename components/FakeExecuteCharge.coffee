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
        control: true
    outPorts:
      charge:
        datatype: 'object'
      error:
        datatype: 'object'
    description: 'execute a charge created in a previous step'
    icon: 'money'
    process: (input, output) ->
      return unless input.has 'data', 'paypal', (ip) -> ip.type is 'data'
      [data, paypal] = input.getData 'data', 'paypal'

      setTimeout ->
        output.sendDone charge:
          'id': data.paymentid
          'create_time': '2013-01-30T23:44:26Z'
          'update_time': '2013-01-30T23:44:28Z'
          'state': 'approved' # data.state
          'intent': 'sale' # data.intent
          'payer':
            'payment_method': 'paypal'
            'payer_info':
              'email': 'bbuyer@example.com'
              'first_name': 'Betsy'
              'last_name': 'Buyer'
              'payer_id': data.payerid # 'CR87QHB7JTRSC'
          'transactions': [ {
            'amount':
              'total': '7.47'
              'currency': 'USD'
              'details':
                'tax': '0.04'
                'shipping': '0.06'
            'description': 'This is the payment transaction description.'
            'related_resources': [ { 'sale':
              'id': '1KE4800207592173L' # data.partentpayment
              'create_time': '2013-01-30T23:44:26Z'
              'update_time': '2013-01-30T23:44:28Z'
              'state': 'completed'
              'amount':
                'currency': 'USD'
                'total': '7.47'
              'transaction_fee':
                'value': '0.50'
                'currency': 'USD'
              'parent_payment': 'PAY-34629814WL663112AKEE3AWQ'
              'links': [
                {
                  'href': 'https://api.sandbox.paypal.com/v1/payments/sale/'+data.paymentid+''
                  'rel': 'self'
                  'method': 'GET'
                }
                {
                  'href': 'https://api.sandbox.paypal.com/v1/payments/sale/'+data.paymentid+'/refund'
                  'rel': 'refund'
                  'method': 'POST'
                }
                {
                  'href': 'https://api.sandbox.paypal.com/v1/payments/payment/PAY-34629814WL663112AKEE3AWQ'
                  'rel': 'parent_payment'
                  'method': 'GET'
                }
              ] } ]
          } ]
          'links': [ {
            'href': 'https://api.sandbox.paypal.com/v1/payments/payment/'+data.paymentid
            'rel': 'self'
            'method': 'GET'
          } ]
      , 5000
