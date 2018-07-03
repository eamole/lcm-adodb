locomotive = require('locomotive')
Controller = locomotive.Controller

Db = require('../db');



class TC extends Controller

  constructor : ->
    super()
    @primary = new Db "primary" , "E:\\ResMgr\\amdex\\resmanager" , "AERLINGUS"
    @snapshot = new Db "snapshot" , "E:\\ResMgr\\amdex\\resmanager_snapshot"

  index : ->
    @primary.getTables @show

  show : =>
    @title="Hello World"
    @tables=@primary.tables # locomotive filters all properties existing prior to action !!
    @render();


module.exports=TC