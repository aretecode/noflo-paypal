# UpdateCharge component updates a description or metadata
# for an existing charge.
noflo = require 'noflo'

exports.getComponent = ->
  new noflo.Component
    description: 'Create Plan for Regular'
    icon: 'repeat|refresh'
    inPorts:
      id:
        datatype: 'string'
        required: true
        description: 'Charge ID'
      description:
        datatype: 'string'
        control: true
        required: false
        description: 'Charge description (optional if metadata is provided)'
      data:
        datatype: 'object'
        control: true
      metadata:
        datatype: 'object'
        required: false
        control: true
        description: 'Charge metadata (optional if description is provided)'
      paypal:
        datatype: 'object'
        description: 'Configured Paypal client'
        required: true
    outPorts:
      charge:
        datatype: 'object'
      error:
        datatype: 'object'
    process: (input, output) ->
      return unless input.has 'id', 'paypal'
      [id, paypal] = input.getData 'id', 'paypal'
      return unless input.ip.type is 'data'

      [description, metadata] = input.getData 'description', 'metadata'
      unless description or metadata
        return output.sendDone noflo.helpers.CustomError 'Description or metadata has to be provided',
          kind: 'internal_error'
          code: 'missing_charge_update_data'
          param: if description then 'metadata' else 'description'

      data = {}
      data.description = description if description
      data.metadata = metadata if metadata

      paypal.charges.update id, data, (err, charge) ->
        return output.sendDone err if err
        output.sendDone charge: charge
