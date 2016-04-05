# UpdateCharge component updates a description or metadata
# for an existing charge.
noflo = require 'noflo'

exports.getComponent = ->
  new noflo.Component
    inPorts:
      id:
        datatype: 'all'
        description: 'Charge ID'
        required: true
      description:
        datatype: 'string'
        description: 'Charge description (optional if metadata is provided)'
        required: false
      metadata:
        datatype: 'object'
        description: 'Charge metadata (optional if description is provided)'
        required: false
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
      [id, paypal, description, metadata] = input.getData 'id', 'paypal', 'description', 'metadata'
      return unless input.ip.type is 'data'

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
