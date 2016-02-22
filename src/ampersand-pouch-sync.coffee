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
          .then (resp) ->
            options.success resp
          .catch (err) ->
            if options?.error? then options.error err
            else throw err
        else if options.query is 'allDocs'
          db.allDocs
            include_docs: true
          .then (resp) ->
            options.success resp
          .catch (err) ->
            if options?.error? then options.error err
            else throw err
        else
          query = (q) ->
            db.query q,
              include_docs: true
            .then (resp) ->
              options.success resp
            .catch (err) ->
              if options?.error? then options.error err
              else throw err
          if options.options?
            design = options.options[options.query]
            if (typeof design) is 'function'
              query design
            else if (typeof design) is 'object'
              if design.fun?
                query design.fun
              else
                throw Error 'Please define a map and reduce function'
          else
            query options.query
      post: ->
        body = model.toJSON()
        db.post body
        .then (resp) ->
          console.log 'asdf', resp
          body._id = resp.id
          body._rev = resp.rev
          options.success body, resp
        .catch (err) ->
          console.log 'error 123', err
          if options?.error? then options.error err
          else throw err
      put: ->
        body = model.toJSON()
        db.put body, body._id, body._rev
        .then (resp) ->
          body._rev = resp.rev
          options.success body, resp
        .catch (err) ->
          if options?.error? then options.error err
          else throw err
      remove: ->
        db.remove model._id, model._rev
        .then (resp) ->
          options.success()
        .catch (err) ->
          if options?.error? then options.error err
          else throw err

    code = methods[method]
    actions[code]()
  adapter.defaults = defaults
  adapter.pouchDB = db
  adapter
