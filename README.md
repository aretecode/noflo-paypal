# Noflo-Paypal

[![Build Status](https://travis-ci.org/aretecode/noflo-paypal.svg)](https://travis-ci.org/aretecode/noflo-paypal)

[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

# @TODO
* [x] Convert to new noflo `process` API
* [ ] Add Graphs - examples with API Key & ConfigurePaypal
* [ ] Change `tests/` to use .noflo.json insteadof requiring the component files
* [ ] Add full functionality for listed requirements
* [ ] Remove hardcoded parts from Components and put them into tests
* [ ] Split tests up
* [x] Change tests to Grunt
* [ ]
* [ ] Improve CreateCharge
* [ ] ^ add CreateChargeJson ? Add ports for each property?
* [ ] Improve Subscription

* [ ] Validate .intent @enum (sale, authorize, or order)
* [ ] TODO test other ListCharges parameters
* [ ] Currency in lowest for PayPal, convert?
* [ ] Create&GetCustomer?
* [ ] Improve Payout, make dynamic
* [ ] Subscription & Others, add URL ports (or improve API, at least have it come in some port)
* [ ] Reevaluate UpdateCharge
* [ ] Test, should create a new charge using saved credit card
* [x] RecieveCard test - why isn't it loading? (was using the same card)

## Components

### Initial drafts (Round one)
* [x] Charge customers
* [x] Make payment subscriptions
* [x] Send money to customers
* [x] Refunds
* [x] Payment history

### Round two
* [ ] Charge customers
* [ ] Make payment subscriptions
* [ ] Send money to customers
* [ ] Refunds
* [ ] Payment history

### Split into sub graphs with full HTTP methods?
* [ ]
* [ ] [https://developer.paypal.com/webapps/developer/docs/api/#common-payments-objects](common objects)
* [ ] [https://developer.paypal.com/webapps/developer/docs/integration/direct/capture-payment/#capture-the-payment](paypal api)
* [x] [https://github.com/svetly/noflo-stripe/blob/master/components/CreateCharge.coffee](current system)

### Resources
* [https://github.com/paypal/PayPal-Node-SDK](Paypal Node SDK)

## Requirements
1) creating an Invoice
2) Requesting Money from an existing Customer
3) having it so they can Send Money to you that is not a Subscription
4) combination of the above?
5) something else?
