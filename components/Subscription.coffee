###
https://github.com/paypal/PayPal-node-SDK/blob/master/samples/subscription/billing_plans/update.js
https://github.com/paypal/PayPal-node-SDK/tree/master/samples/subscription/billing_plans
https://github.com/paypal/PayPal-node-SDK/tree/master/samples/subscription
https://developer.paypal.com/docs/classic/express-checkout/ht_ec-recurringPaymentProfile-curl-etc/
###
noflo = require 'noflo'

exports.getComponent = ->
  new noflo.Component
    description: 'Create Plan for Regular'
    icon: 'repeat|refresh'
    inPorts:
      urls:
        datatype: 'object'
      intervalname:
        datatype: 'string'
      data:
        datatype: 'object'
      paypal:
        datatype: 'object'
        description: 'Configured Paypal client'
        required: true
        control: true
    outPorts:
      sub:
        datatype: 'object'
      error:
        datatype: 'object'
    process: (input, output) ->
      return unless input.has 'data', 'paypal', (ip) -> ip.type is 'data'
      [payload, paypal] = input.getData 'data', 'paypal'

      # ENSURE IT HAS PROPERTIES LIKE SETUP FEE
      # ENSURE TYPE IS ENUM
      # ENSURE FREQUENCY IS CAPITALS & is enum (month year etc)

      billingPlan =
        description: 'Create Plan for Regular'
        name: 'Testing1-Regular1'
        merchant_preferences:
          auto_bill_amount: 'yes'
          cancel_url: 'http://www.cancel.com'
          return_url: 'http://www.success.com'
          initial_fail_amount_action: 'continue'
          max_fail_attempts: '1'
          setup_fee:
            currency: 'USD'
            value: '25'

      if Array.isArray payload.definitions
        billingPlan.payment_definitions = payload.definitions
      else
        paymentDefinition =
          amount: payload.definitions.amount
          charge_models: payload.definitions.charge_models

        paymentDefinition.cycles = payload.definitions.cycles or '0'
        paymentDefinition.frequency = payload.definitions.frequency or 'MONTH'
        paymentDefinition.frequency_interval = payload.definitions.frequency_interval or '1'
        paymentDefinition.name = payload.definitions.type or 'Regular 1'
        paymentDefinition.type = payload.definitions.type or 'REGULAR'

        billingPlan.payment_definitions = [paymentDefinition]

      ################
      # BILLING PLAN
      billingPlan.description = payload.description if payload.description
      billingPlan.name = payload.name if payload.name
      billingPlan.type = payload.type or 'INFINITE'
      if payload.merchant_preferences?
        billingPlan.merchant_preferences = payload.merchant_preferences
      else
        billingPlan.merchant_preferences =
          auto_bill_amount: 'yes'
          initial_fail_amount_action: 'continue'
          max_fail_attempts: '1'
        billingPlan.merchant_preferences.setup_fee = payload.setup_fee # if payload.setup_fee
        billingPlan.merchant_preferences.cancel_url = payload.cancel_url if payload.cancel_url
        billingPlan.merchant_preferences.return_url = payload.return_url if payload.return_url

      # console.log ' SUBSCRIPTION COMPONENT NPM ', JSON.stringify(billingPlan, null, 2)

      paypal.billingPlan.create JSON.stringify(billingPlan), (err, billingPlan) ->
        return output.sendDone err if err
        output.sendDone sub: billingPlan
