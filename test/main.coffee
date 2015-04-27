PouchCollection = require 'ampersand-pouch-collection'
PouchModel = require 'ampersand-pouch-model'
PouchDB = require 'pouchdb'

TestModel = PouchModel.extend
  idAttribute: '_id'
  pouch:
    dbName: 'test_database'
  props:
    title: 'string'

TestCollection = PouchCollection.extend
  mainIndex: '_id'
  model: TestModel
  pouch:
    dbName: 'test_database'
    options:
      foo:
        fun:
          map: (doc) -> emit doc if doc.title is 'foo'

it 'should create model', (done) ->
  title = 'i am a test model'
  model = new TestModel
    title: title
  model.save null,
    success: (model) ->
      model.should.be.a.Object
      model.should.have.a.property model.idAttribute
      model.should.have.a.property 'title'
        .and.be.exactly title
      done()

it 'should update model', (done) ->
  model = new TestModel
    title: 'i am a test model'
  model.should.not.have.a.property '_rev'
  model.save null,
    success: (model) ->
      model.should.have.a.property '_rev'
      changedTitle = 'am i changed?'
      rev = model._rev
      model.title = changedTitle 
      model.save null,
        success: (model) ->
          model.should.be.a.Object
          model.should.have.a.property model.idAttribute
          model.should.have.a.property '_rev'
          model._rev.should.not.be.equal rev
          model.should.have.a.property 'title'
            .and.be.exactly changedTitle
          done()

it 'should delete model', (done) ->
  model = new TestModel
    title: 'i am a test model'
  model.on 'destroy', ->
    should.be.ok
    done()
  model.save null,
    success: (model) ->
      model.destroy()

it 'should fetch all from collection', (done) ->
  collection = new TestCollection
  foo = 
    title: 'foo'
  collection.create foo,
    success: (resp) ->
      collection.fetch
        success: (collection) ->
          collection.should.be.a.Object
          collection.length.should.be.exactly 1
          done()

it 'should query collection', (done) ->
  collection = new TestCollection
  foo = 
    title: 'foo'
  bar = 
    title: 'bar'
  collection.create foo,
    success: (resp) ->
      collection.create bar,
        success: ->
          collection.fetch
            query: 'foo'
            success: (collection) ->
              collection.should.be.a.Object
              collection.length.should.be.exactly 1
              done()

afterEach (done) ->
  db = new PouchDB 'test_database'
  db.destroy().then -> done()
