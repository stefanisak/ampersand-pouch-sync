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
            return db.get(model._id).then(function(resp) {
              return options.success(resp);
            })["catch"](function(err) {
              if ((options != null ? options.error : void 0) != null) {
                return options.error(err);
              } else {
                throw err;
              }
            });
          } else if (options.query === 'allDocs') {
            return db.allDocs({
              include_docs: true
            }).then(function(resp) {
              return options.success(resp);
            })["catch"](function(err) {
              if ((options != null ? options.error : void 0) != null) {
                return options.error(err);
              } else {
                throw err;
              }
            });
          } else {
            query = function(q) {
              return db.query(q, {
                include_docs: true
              }).then(function(resp) {
                return options.success(resp);
              })["catch"](function(err) {
                if ((options != null ? options.error : void 0) != null) {
                  return options.error(err);
                } else {
                  throw err;
                }
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
          var body;
          body = model.toJSON();
          return db.post(body).then(function(resp) {
            body._id = resp.id;
            body._rev = resp.rev;
            return options.success(body, resp);
          })["catch"](function(err) {
            if ((options != null ? options.error : void 0) != null) {
              return options.error(err);
            } else {
              throw err;
            }
          });
        },
        put: function() {
          var body;
          body = model.toJSON();
          return db.put(body, body._id, body._rev).then(function(resp) {
            body._rev = resp.rev;
            return options.success(body, resp);
          })["catch"](function(err) {
            if ((options != null ? options.error : void 0) != null) {
              return options.error(err);
            } else {
              throw err;
            }
          });
        },
        remove: function() {
          return db.remove(model._id, model._rev).then(function(resp) {
            return options.success();
          })["catch"](function(err) {
            if ((options != null ? options.error : void 0) != null) {
              return options.error(err);
            } else {
              throw err;
            }
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
