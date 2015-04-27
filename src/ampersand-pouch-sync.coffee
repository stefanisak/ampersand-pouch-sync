PouchDB = require 'pouchdb'
_ = require 'underscore'

dbNameError = -> throw new Error 'A database name must be specified'

methods = 
  'create': 'post'
  'update': 'put'
  'patch':  'put'
  'delete': 'remove'
  'read':   'get'

module.exports = (defaults) ->
  settings =
    defaults:
      dbName: null
      dbOptions: {}
      query: 'allDocs'
  defaults = defaults || {}
  defaults = _.extend settings.defaults, defaults

  db = new PouchDB defaults.dbName, defaults.dbOptions

  adapter = (method, model, options) ->
    options = options || {}
    options = _.extend defaults, model && model.pouch || {}, options

    actions =
      get: ->
        if model._id?
          db.get model._id
          .then (response) ->
            options.success response
          .catch (err) ->
            options.error err
        else if options.query is 'allDocs'
          db.allDocs
            include_docs: true
          .then (response) ->
            options.success response
          .catch (err) ->
            options.error err
        else
          query = (q) ->
            db.query q,
              include_docs: true
            .then (response) ->
              options.success response
            .catch (err) ->
              options.error err
          if options.options?
            design = options.options[options.query]
            if (typeof design) is 'Function'
              query design
            else if (typeof design) is 'Object'
              if design.map? and design.reduce?
                query design
              else
                throw Error 'Please define a map and reduce function'
          else
            query options.query
      post: ->
        db.post model.toJSON()
        .then (response) ->
          model._id = response.id
          model._rev = response.rev
          options.success model, response, options
        .catch (err) ->
          options.error err
      put: ->
        db.put model.toJSON(), model._id, model._rev 
        .then (response) ->
          model._rev = response.rev
          options.success model, response, options
        .catch (err) ->
          options.error err
      remove: ->
        db.remove model._id, model._rev 
        .then (response) ->
          options.success()
        .catch (err) ->
          options.error err

    code = methods[method]
    actions[code]()
  adapter.defaults = defaults
  adapter.pouchDB = db
  adapter
