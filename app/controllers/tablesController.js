// Generated by CoffeeScript 2.3.1
(function() {
  var Controller, Db, TC, jade, locomotive, primary, snapshot,
    boundMethodCheck = function(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new Error('Bound instance method accessed before binding'); } };

  locomotive = require('locomotive');

  Controller = locomotive.Controller;

  Db = require('../db');

  jade = require('jade');

  primary = new Db("primary", "E:\\ResMgr\\amdex\\resmanager", "AERLINGUS");

  snapshot = new Db("snapshot", "E:\\ResMgr\\amdex\\resmanager_snapshot");

  TC = class TC extends Controller {
    constructor() {
      console.log("TC.constructor()");
      super();
      this.showAll = this.showAll.bind(this);
      // note these method ALL take table as a parameter
      // any way to standardise these api calls??
      this.count = this.count.bind(this);
      this.show = this.show.bind(this);
      // not really much value in assigning them here - BUT do not recreate the objects - lose data!!
      this.primary = primary;
      this.snapshot = snapshot;
    }

    exrender(name, tmpl) {
      var fn;
      // this needs to send precompiled jade templates to the browser
      fn = jade.compileClient(tmpl, {
        name: name
      });
      // include in the output
      this.templates[name] = fn;
      return this.super(name);
    }

    // this needs to run to load the table data
    index() {
      console.log("TC.index()");
      return this.primary.getFields().then(() => { // should possibly change this over to load meta for each file - not fields file
        return this.showAll();
      });
    }

    showAll() {
      boundMethodCheck(this, TC);
      console.log("TC.showAll() - live reload? NO!! Oh!! Yes!!");
      this.title = "Tables in Database";
      // have to convert to array!! Can't iterate over objects apparently!!
      this.tables = Object.values(this.primary.tables); // locomotive filters all properties existing prior to action !!
      return this.render();
    }

    countAll() {
      var k, promises, ref, table;
      promises = [];
      ref = this.primary.tables;
      // obj not array
      for (k in ref) {
        table = ref[k];
        promises.push(table.getCount());
      }
      return Promise.all(promises).then(() => {
        return this.showAll();
      });
    }

    count() {
      boundMethodCheck(this, TC);
      console.log("TC.count()");
      this.tableName = this.params('name');
      this.table = this.primary.getTable(this.tableName);
      return this.table.getCount().then(() => { // fat @
        this.render('show');
        return console.log("count Rendered");
      });
    }

    show() { // fat cos called statically
      boundMethodCheck(this, TC);
      console.log("TC.show()");
      this.tableName = this.params('name');
      this.table = this.primary.getTable(this.tableName);
      return this.table.getData().then(() => { // fat @
        this.render();
        return console.log("show Rendered");
      });
    }

    scan() {}

    // reads the records to a cache
    read() {
      console.log("TC.read()");
      this.tableName = this.params('name');
      this.table = this.primary.getTable(this.tableName);
      return this.table.adodbGetData().then(() => { // fat @
        return this.render("show");
      });
    }

    // reads the records to a cache
    inserts() {
      console.log("TC.inserts()");
      this.tableName = this.params('name');
      this.table = this.primary.getTable(this.tableName);
      return this.primary.query(`SELECT * FROM ${this.table.name} WHERE ${this.table.primaryKey}  NOT IN (SELECT record_id FROM ${snapshot.path}.changes WHERE table_id = ${this.table.id});`).then((data) => {
        console.log("Got data");
        this.table.data = data;
        return this.render("show");
      });
    }

    meta() {
      console.log("TC.inserts()");
      this.tableName = this.params('name');
      this.table = this.primary.getTable(this.tableName);
      return this.table.meta().then(() => {
        return this.table.getData();
      }).then(() => {
        return this.render("show");
      });
    }

  };

  module.exports = TC;

}).call(this);

//# sourceMappingURL=tablesController.js.map
