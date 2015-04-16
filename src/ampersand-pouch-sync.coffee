PouchDB = require 'pouchdb'
_ = require 'underscore'

dbNameError = -> throw new Error 'A database name must be specified'

methods = 
  'create': 'post'
  'update': 'put'
  'patch':  'put'
  'delete': 'remove'
  'read':   'get'

settings =
  defaults:
    dbName: null,
    fetch: 'allDocs'

module.exports = (defaults) ->
  defaults = defaults || {}
  defaults = _.extend settings.defaults, defaults

  db = new PouchDB defaults.dbName

  adapter = (method, model, options) ->
    options = options || {}
    options = _.extend defaults, model && model.pouch || {}, options

    actions =
      get: ->
        if options.fetch is 'allDocs'
          db.allDocs
            include_docs: true
          .then (response) ->
            options.success response
          .catch (err) ->
            options.error err
        else
          query = (q) ->
            db.query q
            .then (response) ->
              options.success response
            .catch (err) ->
              options.error err
          if options.options[options.fetch].fun?
            query options.options[options.fetch].fun
          else
            db.get options.options[options.fetch]
            .then (response) ->
              query options.options[options.fetch]
            .catch (err) ->
              options.error err
      post: ->
        db.post model.toJSON()
        .then (response) ->
          model[model.idAttribute] = response.id
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
  adapter
