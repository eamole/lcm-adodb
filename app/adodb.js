// Generated by CoffeeScript 2.3.1
(function() {
  var adodb, edge;

  edge = require('edge-js');

  adodb = (function() {
    class adodb {
      constructor() {
        this.query = this.query.bind(this);
        this.callMethod = this.callMethod.bind(this);
      }

      //spoof node-adodb
      // could actually send this I guess -
      open(cnnString) {
        return this;
      }

      // need to add this method to  c# class
      schema() {
        return this;
      }

      query(sql) {
        this.defineMethod('Query');
        return this.callMethod({
          sql: sql
        });
      }

      defineMethod(methodName) {
        this.methodName = methodName;
        return this.method = edge.func({
          assemblyFile: this.assemblyFile,
          methodName: this.methodName
        });
      }

      callMethod(payload = {}) {
        return new Promise((resolve, reject) => {
          return this.method(payload, (err, data) => {
            if (err) {
              console.log(`Adodb Error : ${err}`);
              return reject(err);
            } else {
              return resolve(data);
            }
          });
        });
      }

    };

    adodb.prototype.assemblyFile = 'c:/dev/rmplus/ConsoleApp2/ConsoleApp2/bin/Debug/Adodb.dll';

    adodb.prototype.typeNme = 'Adodb.Adodb';

    return adodb;

  }).call(this);

  module.exports = new adodb;

}).call(this);

//# sourceMappingURL=adodb.js.map
