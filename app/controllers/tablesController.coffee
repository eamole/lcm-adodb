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
    @primary.getFields()
      .then =>
        @showAll()     # should possibly change this over to load meta for each file - not fields file

  showAll : =>
    console.log "TC.showAll()"
    @title="Tables in Database"
    # have to convert to array!! Can't iterate over objects apparently!!
    @tables=Object.values(@primary.tables) # locomotive filters all properties existing prior to action !!
    @render()

  countAll : ->
    promises=[]
    for k,table of @primary.tables  # obj not array
      promises.push table.getCount()

    Promise.all(promises)
      .then =>
        @showAll()
  # note these method ALL take table as a parameter
  # any way to standardise these api calls??
  count : =>
    console.log "TC.count()"
    @tableName = @params('name')
    @table = @primary.getTable @tableName
    @table.getCount()
      .then =>  # fat @
        @render('show')
        console.log "count Rendered"

  show : => # fat cos called statically
      console.log "TC.show()"
      @tableName = @params('name')
      @table = @primary.getTable @tableName
      @table.getData()
        .then =>  # fat @
          @render()
          console.log "show Rendered"

  scan : ->

  # reads the records to a cache
  read : ->
    console.log "TC.read()"
    @tableName = @params('name')
    @table = @primary.getTable @tableName
    @table.adodbGetData()
      .then => # fat @
        @render "show"

  # reads the records to a cache
  inserts : ->
    console.log "TC.inserts()"
    @tableName = @params('name')
    @table = @primary.getTable @tableName
    @primary.query "SELECT * FROM #{@table.name} WHERE #{@table.primaryKey}  NOT IN (SELECT record_id FROM #{snapshot.path}.changes WHERE table_id = #{@table.id});"
      .then (data) =>
        console.log "Got data"
        @table.data = data;
        @render "show"

  meta : ->
    console.log "TC.inserts()"
    @tableName = @params('name')
    @table = @primary.getTable @tableName
    @table.meta()
      .then =>
        @table.getData()
      .then =>
        @render "show"

module.exports=TC