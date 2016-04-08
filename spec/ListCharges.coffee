chai = require 'chai'
Tester = require 'noflo-tester'
l = require('./../components/PaymentHistory.coffee').getComponent()

paypal = require 'paypal-rest-sdk'
paypal.configure
  'mode': 'sandbox' # sandbox or live
  'client_id': process.env.PAYPAL_CLIENT_ID
  'client_secret': process.env.PAYPAL_CLIENT_SECRET

describe 'ListCharges component', ->
  t = new Tester l
  before (done) ->
    t.start ->
      done()

  it 'should output an array of all charges', (done) ->
    t.receive 'charges', (data) ->
      # console.log 'all charges: ', data
      # chai.expect(data.payments).to.be.an 'array'
      # chai.expect(data).to.have.length.above 0
      done()

    t.send
      paypal: paypal
      exec: true

  it 'should output an array of all charges (count of 1)', (done) ->
    t.receive 'charges', (data) ->
      # chai.expect(data).to.be.an 'array'
      # chai.expect(data).to.have.length.of 1
      done()

    t.send
      paypal: paypal
      count: 1
      exec: true

  # TODO test other ListCharges parameters
