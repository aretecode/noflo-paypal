chai = require 'chai'
Tester = require 'noflo-tester'

# for testing
paypal = require 'paypal-rest-sdk'
paypal.configure
  'mode': 'sandbox' # sandbox or live
  'client_id': process.env.PAYPAL_CLIENT_ID
  'client_secret': process.env.PAYPAL_CLIENT_SECRET

describe 'Payment component', ->
  t = new Tester 'paypal/Payout'

  before (done) ->
    t.start ->
      done()

  it 'should send a payout', (done) ->
    t.receive 'out', (data) ->
      done()

    t.receive 'error', (err) ->
      throw new Error err
      done data

    t.send
      paypal: paypal

    sender_batch_id = Math.random().toString(36).substring(9)
    data =
      'sender_batch_header':
        'sender_batch_id': sender_batch_id
        'email_subject': 'You have a payment'
      'items': [
        {
          'recipient_type': 'EMAIL'
          'amount':
            'value': 0.99
            'currency': 'USD'
          'receiver': 'shirt-supplier-one@mail.com'
          'note': 'Thank you.'
          'sender_item_id': 'item_1'
        }
        {
          'recipient_type': 'EMAIL'
          'amount':
            'value': 0.90
            'currency': 'USD'
          'receiver': 'shirt-supplier-two@mail.com'
          'note': 'Thank you.'
          'sender_item_id': 'item_2'
        }
        {
          'recipient_type': 'EMAIL'
          'amount':
            'value': 2.00
            'currency': 'USD'
          'receiver': 'shirt-supplier-three@mail.com'
          'note': 'Thank you.'
          'sender_item_id': 'item_3'
        }
      ]

    # Pay 50c
    t.send
      paypal: paypal
      data: data
