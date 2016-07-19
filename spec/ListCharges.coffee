chai = require 'chai'
Tester = require 'noflo-tester'

paypal = require 'paypal-rest-sdk'
paypal.configure
  'mode': 'sandbox' # sandbox or live
  'client_id': process.env.PAYPAL_CLIENT_ID
  'client_secret': process.env.PAYPAL_CLIENT_SECRET

describe 'ListCharges component', ->
  t = new Tester 'paypal/PaymentHistory'
  before (done) ->
    t.start ->
      done()

  it 'should output an array of all charges', (done) ->
    t.outs.charges.once 'data', (data) ->
      chai.expect(data.payments).to.be.an 'array'
      chai.expect(data.payments).to.have.length.above 0
      done()

    t.send
      paypal: paypal
      exec: true

  it 'should output an array of all charges (count of 1)', (done) ->
    t.outs.charges.once 'data', (data) ->
      chai.expect(data.payments).to.be.an 'array'
      chai.expect(data.payments).to.have.length.above 0
      done()
    t.send
      paypal: paypal
      count: 1
      exec: true

  # TODO test other ListCharges parameters
