var locomotive = require('locomotive')
    , Controller = locomotive.Controller;

var {db} = require('db');



/*
    ODBC insists in win \ not /
 */
const primaryDb = "E:\\ResMgr\\amdex\\resmanager";
const primaryDbFile = primaryDb + ".mdb";
const changesDb = "E:\\ResMgr\\amdex\\resmanager_snapshot";
const changesDbFile = changesDb + ".mdb";

const ADODB = require('node-adodb');
const primary = ADODB.open('Provider=Microsoft.ACE.OLEDB.12.0;Data Source=' + primaryDbFile + ';Jet OLEDB:Database Password=AERLINGUS');
const changes = ADODB.open('Provider=Microsoft.ACE.OLEDB.12.0;Data Source=' + changesDbFile + ';');


var tc = new Controller();

tc.index_old = function(){
    that=this;
    this.schema = primary.schema(20, function() {
        console.log(JSON.stringify(this.schema, null, 2));
        this.title = "Tables";
        this.render();
    });    // tables


}
tc.index = function() {
    var that=this;
    primary
        .schema(20)
        .then(schema => {
            that.schema=schema;
            // console.log(JSON.stringify(schema, null, 2));
        })
        .then( ()=> {
            that.render();
        })
        .catch(error => {
            console.error(error);
        });
}

tc.show = function() {

    const name = this.param("name");
    this.tableName = name;
    console.log("fetching table structure for "+name);
    var that=this;
    primary
        .schema(4 , [,,name] )  //
        .then(schema => {
            that.columns=schema;
            console.log(JSON.stringify(schema, null, 2));
        })
        .then( ()=> {
            that.render();
        })
        .catch(error => {
            console.error(error);
        });


}

tc.scan = function() {

    const name = this.param("name");
    this.tableName = name;
    console.log("scanning table for inserts/updates/deletes : "+name);
    this.test(name);

}
tc.test = function(tableName) {
    /*
        we need to select all records in A not in B
     */

    const sql = "SELECT * FROM " + primaryDb + "." + tableName;
    console.log( "SQL : " + sql);
    primary
        .query(sql)
        .then(data => {
            console.log(JSON.stringify(data, null, 2));
        })
        .catch(error => {
            console.error(error);
        });
}
tc.inserts = function(tableName) {
    /*
        we need to select all records in A not in B
     */
    primary
        .schema(4 , [,,name] )  //
        .then(schema => {
            that.columns=schema;
            console.log(JSON.stringify(schema, null, 2));
        })
        .then( ()=> {
            that.render();
        })
        .catch(error => {
            console.error(error);
        });
}



module.exports = tc;