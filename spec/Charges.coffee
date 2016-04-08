chai = require 'chai'
uuid = require 'uuid'
Tester = require 'noflo-tester'
c = require('./../components/CreateCharge.coffee').getComponent()
g = require('./../components/GetCharge.coffee').getComponent()
r = require('./../components/RefundCharge.coffee').getComponent()
generator = require 'creditcard-generator'

# for testing
paypal = require 'paypal-rest-sdk'
paypal.configure
  'mode': 'sandbox' # sandbox or live
  'client_id': process.env.PAYPAL_CLIENT_ID
  'client_secret': process.env.PAYPAL_CLIENT_SECRET

describe 'Charges', ->
  charge = null
  secondCharge = null

  describe 'CreateCharge component', ->
    t = new Tester c # 'noflo-paypal/CreateCharge'

    before (done) ->
      t.start ->
        done()

    it 'should fail if currency is missing', (done) ->
      t.receive 'error', (data) ->
        chai.expect(data).to.be.an 'error'
        chai.expect(data.message).to.equal 'Missing currency'
        done()

      t.send
        paypal: paypal
        data:
          amount: 1000000

    it 'should fail if amount is missing', (done) ->
      t.receive 'error', (data) ->
        chai.expect(data).to.be.an 'error'
        chai.expect(data.message).to.equal 'Missing amount'
        done()

      t.send
        paypal: paypal
        data:
          currency: 'EUR'

    # it 'should create a new charge using saved credit card', (done) ->

    it 'should create a new charge using credit card', (done) ->
      t.receive 'charge', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.id).not.to.be.empty
        chai.expect(data.state).to.equal 'approved'
        chai.expect(data.transactions).to.be.an 'array'
        chai.expect(data.transactions[0].amount.total).to.equal '50.00' # could parseint
        chai.expect(data.transactions[0].amount.currency).to.equal 'USD'

        # Save charge object for later reuse
        charge = data
        done()

      t.receive 'error', (data) ->
        console.log data
        throw new Error data
        assert.fail data, null
        done data

      ccNum = generator.GenCC("VISA")[0]

      payer =
        'payment_method': 'credit_card'
        'funding_instruments': [ { 'credit_card':
          'type': 'visa'
          'number': ccNum
          'expire_month': '11'
          'expire_year': '2020'
          'cvv2': '874'
          'first_name': 'Joe'
          'last_name': 'Shopper'
          'billing_address':
            'line1': '52 N Main ST'
            'city': 'Johnstown'
            'state': 'OH'
            'postal_code': '43210'
            'country_code': 'US' } ]

      # Charge 50c
      t.send
        paypal: paypal
        data:
          currency: 'USD'
          amount: 50
          payer: payer

    it 'should create a new charge using credit card (move elsewhere?)', (done) ->
      t.receive 'charge', (data) ->
        secondCharge = data
        done()

      ccNum = generator.GenCC("VISA")[0]

      payer =
        'payment_method': 'credit_card'
        'funding_instruments': [ { 'credit_card':
          'type': 'visa'
          'number': ccNum
          'expire_month': '11'
          'expire_year': '2020'
          'cvv2': '874'
          'first_name': 'Joe'
          'last_name': 'Shopper'
          'billing_address':
            'line1': '52 N Main ST'
            'city': 'Johnstown'
            'state': 'OH'
            'postal_code': '43210'
            'country_code': 'US' } ]

      data =
        currency: 'USD'
        amount: 50
        payer: payer

      # Charge 50c
      t.send
        paypal: paypal
        data: data

  describe 'GetCharge component', ->
    t = new Tester g
    before (done) ->
      t.start ->
        done()

    it 'should fail if non-existend ID is provided', (done) ->
      t.receive 'error', (data) ->
        # chai.expect(data).to.be.an 'object'
        # chai.expect(data.param).to.equal 'id'
        done()

      t.send
        paypal: paypal
        id: "foo-random-invalid-" + uuid.v4()

    it 'should retrieve a charge', (done) ->
      t.receive 'charge', (data) ->
        done()

      t.receive 'error', (data) ->
        console.log data
        throw new Error(data)
        done()

      # chai.expect(data).to.be.an 'object'
      # chai.expect(data).to.deep.equal charge

      t.send
        paypal: paypal
        id: charge.id

  describe 'RefundCharge component', ->
    t = new Tester r
    before (done) ->
      t.start ->
        done()

    it 'should refund a part of the charge if amount is provided', (done) ->
      t.receive 'refund', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.charge).to.equal charge.id
        chai.expect(data.amount).to.equal 20
        done()

      cid = secondCharge
        .transactions[0]
        .related_resources[0]
        .sale
        .id

      t.receive 'error', (data) ->
        throw new Error(data)

      t.receive 'refund', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.sale_id).to.equal cid
        # App fee is not refunded by default
        chai.expect(data.amount.total).to.be.at.least 20
        done()

      # would be refunding 20/50 though
      t.send
        amount: '20.00' # refund 20c @TODO (would default to $)
        currency: 'USD'

      setTimeout ->
        t.send
          paypal: paypal
          id: cid
      , 20000 # 200000


    it 'should refund entire sum left by default', (done) ->
      tryTryAgain = null

      # charge.id
      cid = charge
        .transactions[0]
        .related_resources[0]
        .sale
        .id

      # t.receive 'error', (data) ->
      #   console.log data
      #   throw new Error(data)

      t.receive 'refund', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.sale_id).to.equal cid
        # App fee is not refunded by default
        chai.expect(data.amount.total).to.be.at.least 20
        clearInterval tryTryAgain
        done()

      # console.log JSON.stringify(charge)
      ### @TODO or just keep trying every 30 seconds ###
      ###
      setTimeout ->
        t.send 'id', cid
      , 200000
      ###
      tryTryAgain = setInterval ->
        t.send
          paypal: paypal
          id: cid
      , 10000
