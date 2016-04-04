noflo = require 'noflo'
chai = require 'chai'
uuid = require 'uuid'
Tester = require 'noflo-tester'
c = require('./../components/CreateCardToken.coffee').getComponent()
rc = require('./../components/RetrieveCard.coffee').getComponent()
d = require('./../components/DeleteCard.coffee').getComponent()

# for testing
paypal = require 'paypal-rest-sdk'
paypal.configure
  'mode': 'sandbox' # sandbox or live
  'client_id': process.env.PAYPAL_CLIENT_ID
  'client_secret': process.env.PAYPAL_CLIENT_SECRET

describe 'Tokens', ->
  apiKeys =
    mode: process.env.PAYPAL_MODE or 'sandbox'
    id: process.env.PAYPAL_CLIENT_ID
    secret: process.env.PAYPAL_CLIENT_SECRET
  token = null

  chai.expect(apiKeys).not.to.be.empty

  describe 'CreateCardToken component', ->
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

      t.send 'card',
        number: "4242"
    ###

    it 'should fail if card number or expiry data is missing', (done) ->
      t.receive 'error', (data) ->
        chai.expect(data).to.be.an 'array'
        chai.expect(data).to.have.lengthOf 3
        messages = [
          'Missing card number'
          'Missing or invalid expiration month'
          'Missing or invalid expiration year'
        ]
        for msg in data
          chai.expect(messages).to.include msg.message
        done()

      t.send 'paypal', paypal
      t.send 'card',
        name: 'T. Ester'

    it 'should create a new token', (done) ->
      t.receive 'token', (data) ->
        console.log "\n\n\n\n NEW CARD TOKEN: \n", data.id
        chai.expect(data).to.be.an 'object'
        chai.expect(data.id).not.to.be.empty
        chai.expect(data.state).to.equal 'ok'
        chai.expect(data.type).to.equal 'visa' # |mastercard|americanexpress|?
        # Save charge object for later reuse
        token = data.id
        done()

      t.receive 'error', (data) ->
        assert.fail data, null
        done data

      t.send 'paypal', paypal
      t.send 'card',
        number: "4242424242424242"
        exp_month: 12
        exp_year:  2020
        name: "T. Ester"

  describe 'DeleteCard component', ->
    t = new Tester d
    before (done) ->
      t.start ->
        done()

    it 'should delete a card', (done) ->
      t.receive 'error', (data) ->
        console.log data
        throw new Error(data)

      t.receive 'out', (data) ->
        done()

      t.send 'paypal', paypal
      t.send 'card', token

  describe 'RetrieveCard component', ->
    t = new Tester rc
    before (done) ->
      t.start ->
        done()

    it 'should find/recieve a card', (done) ->

      t.receive 'error', (data) ->
        console.log data
        throw new Error(data)

      ###
      # tryTryAgain = null
      # clearInterval tryTryAgain
      # tryTryAgain = setInterval ->
      #   t.send 'token', token
      # , 10000
      ###

      t.receive 'out', (data) ->
        done()

      setTimeout ->
        t.send 'paypal', paypal
        t.send 'token', token
      , 50000 # 200000
