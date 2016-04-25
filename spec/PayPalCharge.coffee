chai = require 'chai'
Tester = require 'noflo-tester'

# for testing
paypal = require 'paypal-rest-sdk'
paypal.configure
  'mode': 'sandbox' # sandbox or live
  'client_id': process.env.PAYPAL_CLIENT_ID
  'client_secret': process.env.PAYPAL_CLIENT_SECRET

describe 'Charges', ->
  approvedPaypal = null

  # Added this in, the previous test was getting credit card output
  describe 'CreateCharge PAYPAL component', ->
    t = new Tester 'paypal/CreateCharge'

    before (done) ->
      t.start ->
        done()

    it 'should create a new charge (to be authorized) using paypal', (done) ->
      t.receive 'charge', (data) ->
        # console.log "\n\n\n\n\n AUTHORIZED-PAYPAL FROM PAYPAL-CREATE-CHARGE: \n", data, "\n\n\n\n\n"
        paypalAuthorizeCharge = data
        done()

      ###
      data =
        'intent': 'sale'
        'payer': 'payment_method': 'paypal'
        payer_info:
          'tax_id_type': 'BR_CPF'
          'tax_id': 'Fh618775690'

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
      ###
      data =
        currency: 'USD'
        amount: "1.00"
        intent: 'sale'
        description: 'eh'
        payer:
          payment_method: 'paypal'
        items:
          name: 'item'
          sku: 'item'
          price: '1.00'
          currency: 'USD'
          quantity: 1
        redirect_urls:
          return_url: 'http://return.url',
          cancel_url: 'http://cancel.url'

      t.send
        paypal: paypal
        data: data
