###
https://github.com/paypal/PayPal-node-SDK/blob/master/samples/subscription/billing_plans/update.js
https://github.com/paypal/PayPal-node-SDK/tree/master/samples/subscription/billing_plans
https://github.com/paypal/PayPal-node-SDK/tree/master/samples/subscription
###
noflo = require 'noflo'

exports.getComponent = ->
  new noflo.Component
    description: 'Create Plan for Regular'
    icon: 'repeat|refresh'
    inPorts:
      ###
      # string (URL)
      payload.URL.return
      payload.URL.cancel
      ###
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
    outPorts:
      sub:
        datatype: 'object'
      error:
        datatype: 'object'
    process: (input, output) ->
      return unless input.has 'data', 'paypal'
      [payload, paypal] = input.getData 'data', 'paypal'
      return unless input.ip.type is 'data'

      ###
        # string
        payload.name

        # object
        payload.setupFee

        # object
        payload.amount
        # object | array[object]
        payload.definitions.chargeModels

        # payload.setupFee; if payment.setupFee? billingPlanAttributes.setupFee = <
        payload.definitions.amount
      ###

      # 'cancel_url': payload.URL.cancel
      # 'return_url': payload.URL.return
      billingPlanAttributes =
        'description': 'Create Plan for Regular'
        'merchant_preferences':
          'auto_bill_amount': 'yes'
          'initial_fail_amount_action': 'continue'
          'max_fail_attempts': '1'
        'name': 'example' #; payload.name
        'type': 'INFINITE'

      #'payment_definitions': #'definitions' #payment.definitions
      # factory?
      defs =
        'payment_definitions': [
            {
              'amount': payload.definitions.amount
              'cycles': '0'
              'frequency': 'MONTH'
              'frequency_interval': '1'
              'name': 'Regular 1'
              'type': 'REGULAR'
            }
            {
              'amount':
                'currency': 'USD'
                'value': '20'
              'charge_models': [
                {
                  'amount':
                    'currency': 'USD'
                    'value': '10.60'
                  'type': 'SHIPPING'
                }
                {
                  'amount':
                    'currency': 'USD'
                    'value': '20'
                  'type': 'TAX'
                }
              ]
              'cycles': '4'
              'frequency': 'MONTH'
              'frequency_interval': '1'
              'name': 'Trial 1'
              'type': 'TRIAL'
            }
        ]

      defs[0].charge_models = payload.definitions.chargeModels if payload.definitions.chargeModels?

      billingPlanAttributes.payment_definitions = defs

      billingPlanAttributes =
        'description': 'Create Plan for Regular'
        'merchant_preferences':
          'auto_bill_amount': 'yes'
          'cancel_url': 'http://www.cancel.com'
          'initial_fail_amount_action': 'continue'
          'max_fail_attempts': '1'
          'return_url': 'http://www.success.com'
          'setup_fee':
            'currency': 'USD'
            'value': '25'
        'name': 'Testing1-Regular1'
        'payment_definitions': [
          {
            'amount': payload.definitions.amount
            'charge_models': [
              {
                'amount':
                  'currency': 'USD'
                  'value': '10.60'
                'type': 'SHIPPING'
              }
              {
                'amount':
                  'currency': 'USD'
                  'value': '20'
                'type': 'TAX'
              }
            ]
            'cycles': '0'
            'frequency': 'MONTH'
            'frequency_interval': '1'
            'name': 'Regular 1'
            'type': 'REGULAR'
          }
          {
            'amount':
              'currency': 'USD'
              'value': '20'
            'charge_models': [
              {
                'amount':
                  'currency': 'USD'
                  'value': '10.60'
                'type': 'SHIPPING'
              }
              {
                'amount':
                  'currency': 'USD'
                  'value': '20'
                'type': 'TAX'
              }
            ]
            'cycles': '4'
            'frequency': 'MONTH'
            'frequency_interval': '1'
            'name': 'Trial 1'
            'type': 'TRIAL'
          }
        ]
        'type': 'INFINITE'

      # console.log ' SUBSCRIPTION COMPONENT NPM ', billingPlanAttributes

      #console.log paypal, ' PAYPAL IN SUBSCRIPTION'
      paypal.billingPlan.create billingPlanAttributes, (err, billingPlan) ->
        return output.sendDone err if err
        output.sendDone sub: billingPlan
