# https://developer.paypal.com/docs/api/#payments
# https://github.com/paypal/PayPal-node-SDK/tree/master/samples/payout
noflo = require 'noflo'

exports.getComponent = ->
  new noflo.Component
    inPorts:
      data:
        datatype: 'string'
      paypal:
        datatype: 'object'
        description: 'Configured Paypal client'
        required: true
    outPorts:
      out:
        datatype: 'integer'
      error:
        datatype: 'object'
    description: 'send payment'
    icon: 'money'
    process: (input, output) ->
      return unless input.has 'data'
      [data, paypal] = input.getData 'data', 'paypal'
      return unless input.ip.type is 'data'

      sender_batch_id = Math.random().toString(36).substring(9)
      create_payout_json =
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

      paypal.payout.create create_payout_json, (err, payout) ->
        return output.sendDone err if err
        output.sendDone out: payout
