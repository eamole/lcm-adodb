locomotive = require('locomotive')
Controller = locomotive.Controller

Db = require('../db');

primary = new Db "primary" , "E:\\ResMgr\\amdex\\resmanager" , "AERLINGUS"
snapshot = new Db "snapshot" , "E:\\ResMgr\\amdex\\resmanager_snapshot"


class TC extends Controller

  constructor : ->
    super()
    # not really much value in assigning them here - BUT do not recreate the objects - lose data!!
    @primary = primary
    @snapshot = snapshot

  # this needs to run to load the table data
  index : ->
    console.log "TC.index()"
    @primary.getTables @showAll

  showAll : =>
    console.log "TC.showAll()"
    @title="Tables in Database"
    # have to convert to array!! Can't iterate over objects apparently!!
    @tables=Object.values(@primary.tables) # locomotive filters all properties existing prior to action !!
    @render()

  show : => # fat cos called statically
    console.log "TC.show()"
    @tableName = @params('name')
    @table = @primary.getTable @tableName
    @render()
    console.log "Rendered"
  scan : ->


module.exports=TC