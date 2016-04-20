chai = require 'chai'
Tester = require 'noflo-tester'

# for testing
paypal = require 'paypal-rest-sdk'
paypal.configure
  'mode': 'sandbox' # sandbox or live
  'client_id': process.env.PAYPAL_CLIENT_ID
  'client_secret': process.env.PAYPAL_CLIENT_SECRET

describe 'Subscription component', ->
  t = new Tester 'paypal/Subscription'
  before (done) ->
    t.start ->
      done()

  it.skip 'should subscribe & charge with only one subscription', (done) ->
    t.receive 'error', (data) ->
      console.log data
      throw new Error(data)

    t.receive 'sub', (data) ->
      # console.log data
      done()

    t.send
      paypal: paypal
    t.send
      data:
        definitions:
          amount:
            value: 20 # @TODO: WHY IS THIS IN VALUE AND THE OTHER TOTAL
            currency: 'USD'
          cycles: '4'
          frequency: 'MONTH'
          frequency_interval: '1'
          name: 'Trial 1'
          type: 'TRIAL'
          charge_models: [
            {
              amount:
                currency: 'USD'
                value: '10.60'
              type: 'SHIPPING'
            }
            {
              amount:
                currency: 'USD'
                value: '20'
              type: 'TAX'
            }
          ]
        setup_fee:
          currency: 'USD'
          value: '25'
        cancel_url: 'http://www.cancel.com'
        return_url: 'http://www.return.com'

  it 'should subscribe & charge with array of definitions', (done) ->
    t.receive 'error', (data) ->
      console.log data
      throw new Error(data)

    t.receive 'sub', (data) ->
      # console.log data
      done()

    pp = require 'paypal-rest-sdk'
    pp.configure
      'mode': 'sandbox' # sandbox or live
      'client_id': process.env.PAYPAL_CLIENT_ID
      'client_secret': process.env.PAYPAL_CLIENT_SECRET

    t.send
      paypal: pp
    t.send
      data:
        definitions:
          [
            {
              amount:
                value: 20
                currency: 'USD'
              'charge_models': [
                {
                  'amount':
                    'currency': 'USD'
                    'value': '10.60'
                  'type': 'SHIPPING'
                }
                {
                  'amount':
                    'currency': 'USD'
                    'value': '20'
                  'type': 'TAX'
                }
              ]
              'cycles': '0'
              'frequency': 'MONTH'
              'frequency_interval': '1'
              'name': 'Regular 1'
              'type': 'REGULAR'
            }
            {
              'amount':
                'currency': 'USD'
                'value': '20'
              'charge_models': [
                {
                  'amount':
                    'currency': 'USD'
                    'value': '10.60'
                  'type': 'SHIPPING'
                }
                {
                  'amount':
                    'currency': 'USD'
                    'value': '20'
                  'type': 'TAX'
                }
              ]
              'cycles': '4'
              'frequency': 'MONTH'
              'frequency_interval': '1'
              'name': 'Trial 1'
              'type': 'TRIAL'
            }
          ]
        setup_fee:
          currency: 'USD'
          value: '25'
        cancel_url: 'http://www.cancel.com'
        return_url: 'http://www.return.com'

