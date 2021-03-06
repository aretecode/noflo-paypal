# Noflo-Paypal

[![Build Status](https://travis-ci.org/aretecode/noflo-paypal.svg)](https://travis-ci.org/aretecode/noflo-paypal)

[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

# @TODO
* [x] Convert to new noflo `process` API
* [x] Add Graph - examples with API Key & ConfigurePaypal
* [ ] Change `tests/` to use .noflo.json insteadof requiring the component files
* [ ] Add full functionality for listed requirements
* [x] Remove hardcoded parts from Components and put them into tests
* [x] Split tests up
* [x] Change tests to Grunt
* [ ]
* [x] Improve CreateCharge
* [x] Improve Subscription
* [ ] Implement GetBalance
* [ ] Validate .intent @enum (sale, authorize, or order)
* [ ] Test other ListCharges parameters
* [ ] Currency in lowest for PayPal, convert?
* [ ] Create&GetCustomer?
* [x] Improve Payout, make dynamic
* [x] Subscription & Others, add URL ports (or improve API, at least have it come in some port)
* [ ] Reevaluate UpdateCharge
* [ ] Test, should create a new charge using saved credit card
* [x] RecieveCard test - why isn't it loading? (was using the same card)

### Split into sub graphs with full HTTP methods?
* [ ] [https://developer.paypal.com/webapps/developer/docs/api/#common-payments-objects](common objects)
* [ ] [https://developer.paypal.com/webapps/developer/docs/integration/direct/capture-payment/#capture-the-payment](paypal api)
* [x] [https://github.com/svetly/noflo-stripe/blob/master/components/CreateCharge.coffee](current system)

### Resources
* [https://github.com/paypal/PayPal-Node-SDK](Paypal Node SDK)
* [https://developer.paypal.com/docs/integration/web/accept-paypal-payment/#specify-payment-information-to-create-a-payment](Create->Approve->Execute)
