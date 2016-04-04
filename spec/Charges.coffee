chai = require 'chai'
uuid = require 'uuid'
Tester = require 'noflo-tester'
c = require('./../components/CreateCharge.coffee').getComponent()
x = require('./../components/ExecuteCharge.coffee').getComponent()
g = require('./../components/GetCharge.coffee').getComponent()
u = require('./../components/UpdateCharge.coffee').getComponent()
r = require('./../components/RefundCharge.coffee').getComponent()
l = require('./../components/PaymentHistory.coffee').getComponent()
s = require('./../components/Subscription.coffee').getComponent()

# for testing
paypal = require 'paypal-rest-sdk'
paypal.configure
  'mode': 'sandbox' # sandbox or live
  'client_id': process.env.PAYPAL_CLIENT_ID
  'client_secret': process.env.PAYPAL_CLIENT_SECRET

describe 'Charges', ->
  charge = null
  secondCharge = null
  paypalAuthorizeCharge = null
  approvedPaypal = null

  describe 'CreateCharge component', ->
    t = new Tester c
    tx = new Tester x

    before (done) ->
      t.start ->
        tx.start ->
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

    it 'should fail if currency is missing', (done) ->
      t.receive 'error', (data) ->
        chai.expect(data).to.be.an 'error'
        chai.expect(data.message).to.equal 'Missing currency'
        done()

      t.send 'paypal', paypal
      t.send 'data',
        amount: 1000000

    it 'should fail if amount is missing', (done) ->
      t.receive 'error', (data) ->
        chai.expect(data).to.be.an 'error'
        chai.expect(data.message).to.equal 'Missing amount'
        done()

      t.send 'paypal', paypal
      t.send 'data',
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

      payer =
        'payment_method': 'credit_card'
        'funding_instruments': [ { 'credit_card':
          'type': 'visa'
          'number': '4417119669820331'
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

      t.send 'paypal', paypal
      # Charge 50c
      t.send 'data',
        currency: 'USD'
        amount: 50
        payer: payer

    it 'should create a new charge using credit card (move elsewhere?)', (done) ->
      t.receive 'charge', (data) ->
        secondCharge = data
        done()

      payer =
        'payment_method': 'credit_card'
        'funding_instruments': [ { 'credit_card':
          'type': 'visa'
          'number': '4417119669820331'
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

      t.send 'paypal', paypal
      # Charge 50c
      t.send 'data',
        currency: 'USD'
        amount: 50
        payer: payer

  describe 'GetCharge component', ->
    t = new Tester g
    before (done) ->
      t.start ->
        done()

    ###
    it 'should fail without an API key', (done) ->
      t.receive 'error', (data) ->
        chai.expect(data).to.be.an 'error'
        chai.expect(data.message).to.contain 'API key'
        done()
      t.send 'id', "foo-123"
    ###

    it 'should fail if non-existend ID is provided', (done) ->
      t.receive 'error', (data) ->
        # chai.expect(data).to.be.an 'object'
        # chai.expect(data.type).to.equal 'StripeInvalidRequestError'
        # chai.expect(data.param).to.equal 'id'
        done()

      t.send 'paypal', paypal
      t.send 'id', "foo-random-invalid-" + uuid.v4()

    it 'should retrieve a charge', (done) ->
      t.receive 'charge', (data) ->
        done()

      t.receive 'error', (data) ->
        console.log data
        throw new Error(data)
        done()

      # chai.expect(data).to.be.an 'object'
      # chai.expect(data).to.deep.equal charge

      t.send 'paypal', paypal
      t.send 'id', charge.id

  describe 'RefundCharge component', ->
    t = new Tester r
    before (done) ->
      t.start ->
        done()

    ###
    it 'should fail without an API key', (done) ->
      t.receive 'error', (data) ->
        chai.expect(data).to.be.an 'error'
        chai.expect(data.message).to.contain 'API key'
        done()

      t.send 'id', "foo-123"
    ###

    it 'should refund a part of the charge if amount is provided', (done) ->
      tryTryAgain = null

      ###
      t.receive 'error', (data) ->
        console.log data
        throw new Error(data)
      ###

      t.receive 'refund', (data) ->
        # console.log "\n REEEEFUUUUUUND _____ \n", JSON.stringify(data)
        chai.expect(data).to.be.an 'object'
        chai.expect(data.charge).to.equal charge.id
        chai.expect(data.amount).to.equal 20
        clearInterval tryTryAgain
        done()

      cid = secondCharge
        .transactions[0]
        .related_resources[0]
        .sale
        .id

      #t.receive 'error', (data) ->
      #  throw new Error(data)

      t.receive 'refund', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.sale_id).to.equal cid
        # App fee is not refunded by default
        chai.expect(data.amount.total).to.be.at.least 20
        done()

      t.send 'amount', '20.00' # refund 20c @TODO (would default to $)
      t.send 'currency', 'USD'

      setTimeout ->
        t.send 'paypal', paypal
        t.send 'id', cid
      , 200000

      ###
      setTimeout ->
        tryTryAgain = setInterval ->
          t.send 'id', cid
        , 10000
      , 200000
      ###

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
        # console.log "\n REEEEFUUUUUUND (entire) _____ \n", JSON.stringify(data)

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
        t.send 'paypal', paypal
        t.send 'id', cid
      , 10000

  describe 'ListCharges component', ->
    t = new Tester l
    before (done) ->
      t.start ->
        done()

    ###
    it 'should fail without an API key', (done) ->
      t.receive 'error', (data) ->
        chai.expect(data).to.be.an 'error'
        chai.expect(data.message).to.contain 'API key'
        done()

      t.send 'apikeys', apiKeys
      t.send 'exec', true
    ###

    it 'should output an array of all charges', (done) ->
      t.receive 'charges', (data) ->
        # console.log 'all charges: ', data
        # chai.expect(data.payments).to.be.an 'array'
        # chai.expect(data).to.have.length.above 0
        done()

      t.send 'paypal', paypal
      t.send 'exec', true

    it 'should output an array of all charges (count of 1)', (done) ->
      t.receive 'charges', (data) ->
        # chai.expect(data).to.be.an 'array'
        # chai.expect(data).to.have.length.of 1
        done()

      t.send 'paypal', paypal
      t.send 'count', 1
      t.send 'exec', true

    c.customer = null
    c.end_time = null
    c.count = null
    c.start_id = null
    c.start_time = null
    c.start_index = null
    c.sortby = null

    # TODO test other ListCharges parameters

  describe 'Subscription component', ->
    t = new Tester s
    before (done) ->
      t.start ->
        done()

    it 'should subscribe & charge', (done) ->
      t.receive 'error', (data) ->
        console.log data
        throw new Error(data)

      t.receive 'sub', (data) ->
        # console.log data
        # chai.expect(data).to.be.an 'object'
        # chai.expect(data.id).to.equal cid
        # App fee is not refunded by default
        # chai.expect(data.amount.total).to.be.at.least 20
        done()

      t.send 'paypal', paypal
      t.send 'data',
        definitions:
          amount:
            value: 20 # @TODO: WHY IS THIS IN VALUE AND THE OTHER TOTAL
            currency: 'USD'


  ###
  describe 'UpdateCharge component', ->
    t = new Tester u
    before (done) ->
      t.start ->
        done()

    it 'should fail without an API key', (done) ->
      t.receive 'error', (data) ->
        chai.expect(data).to.be.an 'error'
        chai.expect(data.message).to.contain 'API key'
        done()

      t.send 'id', "foo-123"

    it 'should fail if neither description nor metadata was sent', (done) ->
      # Set API key here as we didn't do it before
      t.send 'apikeys', apiKeys

      t.receive 'error', (data) ->
        chai.expect(data).to.be.an 'error'
        chai.expect(data.message).to.contain 'has to be provided'
        done()

      t.send 'id', charge.id

    it 'should update description or metadata of a charge', (done) ->
      t.receive 'charge', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.id).to.equal charge.id
        chai.expect(data.description).to.equal 'A charge for a test'
        chai.expect(data.metadata).to.deep.equal {foo: 'bar'}
        done()

      t.send
        description: 'A charge for a test'
        metadata:
          foo: 'bar'
        id: charge.id
  ###


  ###
  Added this in, the previous test was getting credit card output
  describe 'CreateCharge PAYPAL component', ->
    t = new Tester c

    before (done) ->
      t.start ->
        done()

    it 'should create a new charge (to be authorized) using paypal', (done) ->
      t.receive 'charge', (data) ->
        console.log "\n\n\n\n\n AUTHORIZED-PAYPAL FROM PAYPAL-CREATE-CHARGE: \n", data, "\n\n\n\n\n"
        paypalAuthorizeCharge = data
        done()

      payer =
        payment_method: 'paypal'
        ## #
        'payer_info':
          'tax_id_type': 'BR_CPF'
          'tax_id': 'Fh618775690'
        ## #

      # @TODO: Charge 50c
      t.send 'data',
        currency: 'USD'
        amount: 50
        payer: payer
        intent: 'sale' # 'authorize'

  describe 'Approve component', ->
    # ALREADY EXECUTED IF IT IS A CREDIT CARD, IF IT IS PAYPAL, IT REQUIRES USER AUTH
    it 'should load the link to approve a `created` PayPal charge', (done) ->
      # .links[1].href
      http = require 'http'
      url = require 'url'

      console.log "\n\n\n authorized-paypal-for-links \n" + JSON.stringify(paypalAuthorizeCharge) + "\n\n\n"

      approveUrl = url.parse paypalAuthorizeCharge.links[1].href

      getResultJSON = (res, callback) ->
        data = ''
        res.on 'data', (chunk) ->
          data += chunk
        res.on 'end', ->
          try
            callback JSON.parse(JSON.stringify(data)).parse(json)
          catch e
            throw new Error e.message + '. Body:' + JSON.stringify(data)

      options =
        hostname: approveUrl.host
        path: approveUrl.path
        method: 'GET'
        # headers:
        #   'Authorization': 'Bearer 123456789'

      console.log approveUrl
      req = (options, done, cb) ->
        try
          request = http.request options, (res) ->
            getResultJSON res, (json) ->
              data = json
              cb data.message, data.body, done
          request.end()
        catch e
          throw new Error(e + " DIDN'T DO REQ")
          done e

      req options, done, (data) -> console.log("\n\n APPROVED-PAYPAL-HTTP-RESULT: \n"); console.log(data); approvedPaypal = data;

  describe 'Execute component', ->
    t = new Tester x

    before (done) ->
      t.start ->
        done()

    # ALREADY EXECUTED IF IT IS A CREDIT CARD, IF IT IS PAYPAL, IT REQUIRES USER AUTH
    it 'should execute an approved created (authorized paypal) charge', (done) ->
      t.receive 'charge', (data) ->
        done()

      t.receive 'error', (data) ->
        console.log data
        throw new Error data
        assert.fail data, null
        done data

      t.send 'data',
        payerid: 'fake id? paypal id? email address?'
        paymentid: paypalAuthorizeCharge.id

  describe 'Create & Approve & Execute component', ->
    it 'Create&Approve&Execute component', (done) ->

    console.log "\n\n\n\n CREATE&APPROVED&EXECUTE \n\n\n"

    paypal = require 'paypal-rest-sdk'
    paypal.configure
      'mode': apiKeys.mode or 'sandbox' # sandbox or live
      'client_id': apiKeys.id
      'client_secret': apiKeys.secret

    create_payment_json =
      'intent': 'authorize'
      'payer': 'payment_method': 'paypal'
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

    paymenting = null
    approveUrl = null

    paypal.payment.create create_payment_json, (error, payment) ->
      paymenting = payment

      if error
        console.log error.response
        throw error
      else
        index = 0
        while index < payment.links.length
          #Redirect user to this endpoint for redirect url
          if payment.links[index].rel == 'approval_url'
            console.log payment.links[index].href
            approveUrl = payment.links[index].href
          index++
        console.log payment
      return

    execute_payment_json =
      'payer_id': 'Appended to redirect url'
      'transactions': [ { 'amount':
        'currency': 'USD'
        'total': '1.00' } ]
    paymentId = 'PAYMENT id created in previous step'
    paymentId = paymenting

    paypal.payment.execute paymentId, execute_payment_json, (error, payment) ->
      if error
        console.log error.response
        throw error
      else
        console.log 'Get Payment Response'
        console.log JSON.stringify(payment)
      return

    setTimeout ->
      paypal.payment.execute paymentId, execute_payment_json, (error, payment) ->
        if error
          console.log error.response
          throw error
        else
          console.log 'Get Payment Response'
          console.log JSON.stringify(payment)
        return
    , 200000
###
