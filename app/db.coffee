ADODB = require('node-adodb');

class Db
  constructor : (@name,@path,@password,@ext=".mdb") ->
    @passString = ""
    @passString = "Jet OLEDB:Database Password=#{@password}" if @password?
    @file = @path + @ext
    @provider = 'Provider=Microsoft.ACE.OLEDB.12.0'
    @tables=[];
    @dataSource = "Data Source=#{@file}"
    @connected = false;

  connect : ->
    cnnString = "#{@provider};#{@dataSource};#{@passString}"
    @cnn = ADODB.open cnnString
    @connected=true;

  # kludge - should return a promise!! - instead using a callback!! needs to be bound
  getTables : (cb) ->
    @connect() if not @connected
    @cnn.schema 20
      .then (@schema) =>  # fat for @ in promise
        for tableObj in @schema
          table = @addTable tableObj['TABLE_NAME']
          table.getFields()
      .then ->
        cb(); # TODO : cb kludge - should be promise
      .catch (e) ->
        console.log "getTables Error : #{e} "

  addTable : (name) ->
    table = new Table(@,name)
    @tables[name] = table
    table

class Table
  constructor : (@db,@name) ->
    @fields=[]

  getFields : ->
    @db.cnn.schema 4 , [null,null,@name]
      .then (@schema) =>  # fat for @ in promise
        for column in @schema
          @addField column
      .catch (e) ->
        console.log "getFields Error : #{e}"

  addField : (column) ->
    field = new Field @,column
    @fields[field.name]=field
    field


class Field
  constructor : (@table,@column) ->
    try
      @name = @column['COLUMN_NAME']
      @itype = @column['DATA_TYPE']
    catch e
      console.log "Field Error : #{e}"
module.exports = Db
