edge = require 'edge-js'


class adodb
  assemblyFile : 'c:/dev/rmplus/ConsoleApp2/ConsoleApp2/bin/Debug/Adodb.dll'
  typeNme : 'Adodb.Adodb'

  #spoof node-adodb
  # could actually send this I guess -
  open : (cnnString) ->
    @

  # need to add this method to  c# class
  schema : ->
    @

  query : (sql) =>
    
    @defineMethod 'Query'
    @callMethod({sql : sql })



  defineMethod : (@methodName) ->
    @method = edge.func {
      assemblyFile : @assemblyFile
      methodName : @methodName
    }

  callMethod : (payload={}) =>
    new Promise (resolve,reject) =>
      @method payload , (err,data) =>
        if err
          console.log "Adodb Error : #{err}"
          reject err
        else
          resolve data


module.exports=new adodb