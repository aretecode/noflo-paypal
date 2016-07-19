# ListCharges c runs a custom query and retrieves a list of charges.
#
# Input/output:
#   https://github.com/paypal/PayPal-node-SDK/blob/master/samples/payment/list.js
#   https://developer.paypal.com/docs/api/#list-payment-resources
noflo = require 'noflo'

exports.getComponent = ->
  new noflo.Component
    description: 'payment history'
    icon: 'chart'
    inPorts:
      customer:
        datatype: 'string'
        description: 'customer ID'
        control: true
      created:
        datatype: 'object'
        description: 'Date filter, see paypal.com/docs/api/node#list_charges'
        control: true
      endtime:
        datatype: 'string'
        description: 'Pagination cursor, last object ID'
        control: true
      count:
        datatype: 'int'
        description: 'Pagination limit/count, defaults to 10' # limit
        control: true
      starttime:
        datatype: 'string'
        control: true
      startindex:
        datatype: 'int' #|string
        control: true
      sortby:
        datatype: 'string'
        control: true
      startid:
        datatype: 'string'
        control: true
      exec:
        datatype: 'bang'
        required: true
        description: 'Runs the query passed to other ports'
      paypal:
        datatype: 'object'
        description: 'Configured Paypal client'
        required: true
        control: true
    ###
      @see https://developer.paypal.com/webapps/developer/docs/api/#paging--filtering
      @param filters object
    ###
    outPorts:
      charges:
        datatype: 'array'
        required: true
        description: 'List of changes'
      hasmore:
        datatype: 'boolean'
        required: true
        description: 'Whether there are more results, optional'
      error:
        datatype: 'object'
      out:
        datatype: 'object'

    process: (input, output) ->
      return unless input.has 'exec', 'paypal', (ip) -> ip.type is 'data'

      customer = input.getData 'customer'
      count = input.getData 'count'
      startid = input.getData 'startid'
      starttime = input.getData 'starttime'
      endtime = input.getData 'endtime'
      sortby = input.getData 'sortby'
      startindex = input.getData 'startindex'
      paypal = input.getData 'paypal'

      # Compile the query
      query = {}
      query.customer = customer if customer
      # query.created = created ifcreated
      query.end_time = endtime if endtime
      query.count = if count then count else 10
      query.start_id = startid if startid
      query.start_time = starttime if starttime # startingafter
      query.start_index = startindex if startindex
      query.sortby = sortby if sortby

      paypal.payment.list query, (err, charges) ->
        return output.sendDone err if err

        output.ports.charges.send charges
        if output.ports.hasmore.isAttached()
          output.send hasmore: charges.has_more
        output.done()
