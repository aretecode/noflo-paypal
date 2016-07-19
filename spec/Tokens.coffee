noflo = require 'noflo'
chai = require 'chai'
uuid = require 'uuid'
Tester = require 'noflo-tester'

# for testing
paypal = require 'paypal-rest-sdk'
paypal.configure
  'mode': 'sandbox' # sandbox or live
  'client_id': process.env.PAYPAL_CLIENT_ID
  'client_secret': process.env.PAYPAL_CLIENT_SECRET

describe 'Tokens', ->
  token = null

  describe 'CreateCardToken component', ->
    t = new Tester 'paypal/CreateCardToken'
    before (done) ->
      t.start ->
        done()

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
        chai.expect(data).to.be.an 'object'
        chai.expect(data.id).not.to.be.empty
        chai.expect(data.state).to.equal 'ok'
        chai.expect(data.type).to.equal 'visa' # |mastercard|americanexpress|?

        # Save charge object for later reuse
        token = data.id
        done()

      t.receive 'error', (err) ->
        console.log err.stack
        throw new Error(err)

      card =
        type: 'visa'
        number: '4417119669820331'
        expire_month: '11'
        expire_year: '2019'
        cvv2: '123'
        first_name: 'Joe'
        last_name: 'Shopper'

      t.send 'paypal', paypal
      t.send 'card', card

  describe 'RetrieveCard component', ->
    t = new Tester 'paypal/RetrieveCard'
    before (done) ->
      t.start ->
        done()

    it 'should find/recieve a card', (done) ->
      t.receive 'error', (err) ->
        console.log err
        throw new Error(err)

      t.outs.out.once 'data', (data) ->
        done()

      setTimeout ->
        t.send 'paypal', paypal
        t.send 'token', token
      , 50000 # 200000 #50000

  describe 'DeleteCard component', ->
    t = new Tester 'paypal/DeleteCard'
    before (done) ->
      t.start ->
        done()

    it 'should delete a card', (done) ->
      t.receive 'error', (err) ->
        console.log err
        throw new Error(err)

      t.receive 'out', (data) ->
        done()

      t.send 'paypal', paypal
      t.send 'card', token
