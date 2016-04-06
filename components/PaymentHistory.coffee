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
      created:
        datatype: 'object'
        description: 'Date filter, see paypal.com/docs/api/node#list_charges'
      endtime:
        datatype: 'string'
        description: 'Pagination cursor, last object ID'
      count:
        datatype: 'int'
        description: 'Pagination limit/count, defaults to 10' # limit
      starttime:
        datatype: 'string'
      startindex:
        datatype: 'int' #|string
      sortby:
        datatype: 'string'
      startid:
        datatype: 'string'
      exec:
        datatype: 'bang'
        required: true
        description: 'Runs the query passed to other ports'
      paypal:
        datatype: 'object'
        description: 'Configured Paypal client'
        required: true
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
      return unless input.has 'exec', 'paypal'
      [customer, endtime, count, startid, starttime, startindex, sortby, paypal] = input.getData 'customer', 'endtime', 'count', 'startid', 'starttime', 'startindex', 'sortby', 'paypal'

      return unless input.ip.type is 'data'

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

        output.send charges: charges
        if output.ports.hasmore.isAttached()
          output.send hasmore: charges.has_more
        output.done()
