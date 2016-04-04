chai = require 'chai'
Tester = require 'noflo-tester'
c = require('./../components/Payout.coffee').getComponent()

# for testing
paypal = require 'paypal-rest-sdk'
paypal.configure
  'mode': 'sandbox' # sandbox or live
  'client_id': process.env.PAYPAL_CLIENT_ID
  'client_secret': process.env.PAYPAL_CLIENT_SECRET

describe 'Payment', ->
  apiKeys =
    mode: process.env.PAYPAL_MODE or 'sandbox'
    id: process.env.PAYPAL_CLIENT_ID
    secret: process.env.PAYPAL_CLIENT_SECRET

  chai.expect(apiKeys).not.to.be.empty

  describe 'Payment component', ->
    t = new Tester c

    before (done) ->
      t.start ->
        done()

    ###
    it 'should fail without an API key', (done) ->
      t.receive 'error', (data) ->
        chai.expect(data).to.be.an 'error'
        chai.expect(data.message).to.contain 'API key'
        done()

      t.send 'data',
        currency: 'USD'
        amount: 10000
    ###

    it 'should send a payout', (done) ->
      t.receive 'out', (data) ->
        done()

      t.receive 'error', (data) ->
        assert.fail data, null
        done data

      t.send 'paypal', paypal
      # Charge 50c
      t.send 'data',
        currency: 'USD'
        amount: 50
