chai = require 'chai'
Tester = require 'noflo-tester'

describe 'ConfigurePaypal using CreateCharge With ConfigurePaypal Graph', ->
  t = new Tester 'noflo-paypal/CreateChargeWithConfigurePaypal'

  before (done) ->
    t.start ->
      done()

  it.skip 'should fail if apikeys are missing', (done) ->
    t.receive 'error', (data) ->
      chai.expect(data).to.be.an 'error'
      done()

    t.send
      apikeys:
        mode: 'sandbox'
        id: process.env.PAYPAL_CLIENT_ID
        secret: process.env.PAYPAL_CLIENT_SECRET
