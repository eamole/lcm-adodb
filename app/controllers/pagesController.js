var locomotive = require('locomotive')
  , Controller = locomotive.Controller;

var pagesController = new Controller();

const ADODB = require('node-adodb');
const connection = ADODB.open('Provider=Microsoft.ACE.OLEDB.12.0;Data Source=E:/ResMgr/amdex/resmanager.mdb;Jet OLEDB:Database Password=AERLINGUS');

connection
    .schema(20)
    .then(schema => {
        console.log(JSON.stringify(schema, null, 2));
    })
    .catch(error => {
        console.error(error);
    });

pagesController.main = function() {
  this.title = 'Locomotive';
  this.render();
}

module.exports = pagesController;
