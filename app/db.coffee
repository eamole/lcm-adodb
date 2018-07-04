ADODB = require('node-adodb');

# ADO constants
adodb :
  schemaEnum :
    columns : 4
    indexes : 12
    procedures : 16
    tables : 20
    providerTypes : 22
    views : 23
    foreignKeys : 27
    primaryKeys : 28
    members : 38

  typeEnum :
    empty : 0
    smallInt : 2
    integer : 3
    single : 4
    double : 5
    currency : 6
    date : 7
    bstr : 8
    idispatch : 9
    error : 10
    boolean : 11
    variant : 12
    iunknown : 13
    decimal : 14
    tinyInt : 15
    unsignedTinyInt : 16

class Db
  constructor : (@name,@path,@password,@ext=".mdb") ->
    @passString = ""
    @passString = "Jet OLEDB:Database Password=#{@password}" if @password?
    @file = @path + @ext
    @provider = 'Provider=Microsoft.ACE.OLEDB.12.0'
    @tables=[];
    @dataSource = "Data Source=#{@file}"
    @connected = false;
    @cache = new JsonCache "storage/db/#{@name}/" , "tables" , @getTables

  connect : ->
    cnnString = "#{@provider};#{@dataSource};#{@passString}"
    @cnn = ADODB.open cnnString
    @connected=true;

  getTable : (name) ->
    console.log "table [#{name} not found in database.tables" if not @tables[name]?
    table = @tables[name]

  # kludge - should return a promise!! - instead using a callback!! needs to be bound
  getTables : (cb) =>           # fat - used as a static callback
    @connect() if not @connected
    @cnn.schema 20
      .then (@schema) =>  # fat for @ in promise
        for tableObj in @schema
          table = @addTable tableObj['TABLE_NAME']
#          table.getFields()
      .then ->
        cb(); # TODO : cb kludge - should be promise
      .catch (e) ->
        console.log "getTables Error : #{e} "

  # single query retuirns all fields, which give you all tables as well
  getFields : (cb) ->
    @connect() if not @connected
    @db.cnn.schema 4 , [null,null,null]
      .then (@schema) =>  # fat for @ in promise
        for fieldObj in @schema
          tableName = tableObj['TABLE_NAME']
          # check if already exists
          table = @addTable @ , tableName if not @tables[tableName]?
          table = @tables[tableName]
          table.addField fieldObj

      .then ->
        cb(); # TODO : cb kludge - should be promise
      .catch (e) ->
        console.log "getFields Error : #{e} "

  addTable : (name) ->
    table = new Table(@,name)
    @tables[name] = table
    table

class Table
  constructor : (@db,@name) ->
    @fields=[]

  dump : ->
    console.log "Hello from table #{@name}"

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
