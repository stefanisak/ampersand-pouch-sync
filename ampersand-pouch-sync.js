// Generated by CoffeeScript 1.9.2
(function() {
  var PouchDB, _, dbNameError, methods;

  PouchDB = require('pouchdb');

  _ = require('underscore');

  dbNameError = function() {
    throw new Error('A database name must be specified');
  };

  methods = {
    'create': 'post',
    'update': 'put',
    'patch': 'put',
    'delete': 'remove',
    'read': 'get'
  };

  module.exports = function(defaults) {
    var adapter, db, settings;
    settings = {
      defaults: {
        dbName: null,
        dbOptions: {},
        query: 'allDocs'
      }
    };
    defaults = defaults || {};
    defaults = _.extend(settings.defaults, defaults);
    db = new PouchDB(defaults.dbName, defaults.dbOptions);
    adapter = function(method, model, options) {
      var actions, code;
      options = options || {};
      options = _.extend(defaults, model && model.pouch || {}, options);
      actions = {
        get: function() {
          var design, query;
          if (model._id != null) {
            return db.get(model._id).then(function(response) {
              return options.success(response);
            })["catch"](function(err) {
              return options.error(err);
            });
          } else if (options.query === 'allDocs') {
            return db.allDocs({
              include_docs: true
            }).then(function(response) {
              return options.success(response);
            })["catch"](function(err) {
              return options.error(err);
            });
          } else {
            query = function(q) {
              return db.query(q, {
                include_docs: true
              }).then(function(response) {
                return options.success(response);
              })["catch"](function(err) {
                return options.error(err);
              });
            };
            if (options.options != null) {
              design = options.options[options.query];
              if ((typeof design) === 'function') {
                return query(design);
              } else if ((typeof design) === 'object') {
                if (design.fun != null) {
                  return query(design.fun);
                } else {
                  throw Error('Please define a map and reduce function');
                }
              }
            } else {
              return query(options.query);
            }
          }
        },
        post: function() {
          return db.post(model.toJSON()).then(function(response) {
            model._id = response.id;
            model._rev = response.rev;
            return options.success(model, response, options);
          })["catch"](function(err) {
            return options.error(err);
          });
        },
        put: function() {
          return db.put(model.toJSON(), model._id, model._rev).then(function(response) {
            model._rev = response.rev;
            return options.success(model, response, options);
          })["catch"](function(err) {
            return options.error(err);
          });
        },
        remove: function() {
          return db.remove(model._id, model._rev).then(function(response) {
            return options.success();
          })["catch"](function(err) {
            return options.error(err);
          });
        }
      };
      code = methods[method];
      return actions[code]();
    };
    adapter.defaults = defaults;
    adapter.pouchDB = db;
    return adapter;
  };

}).call(this);
