ADODB = require('node-adodb');

class Db
  constructor : (@name,@path,@password,@ext=".mdb") ->
    @passString = "Jet OLEDB:Database Password=#{AERLINGUS}{password}" if password?
    @file = @path + @ext
    @provider = 'Provider=Microsoft.ACE.OLEDB.12.0'
    @tables=[];
    @dataSource = "Data Source=#{@file}"
    @onnected = false;

  connect : ->
    @cnn = ADODB.open "#{@provider};#{@dataSource};#{@passString}"
    @onnected=true;

  getTables : ->
    @connect() if not @connected
    @cnn
      .schema 20
      .then @schema ->
        for tableObj in schema
          table = @addTable tableObj['TABLE_NAME']
          table.

  addTable : (name) ->
    table = new Table(@,name)
    @tables[name] = table
    table

class Table
  constructor : (@db,@name) ->

  getFields : ->
    @db.cnn
      .schema(4 , [null,null,@name] )
      .then @schema ->
        for column in schema
          @addField column

  addField : (column) ->
    field = new Field @,column
    field


class Field
  constructor : (@table,@column) ->
    @name = column['COLUMN_NAME']
    @itype = column['DATA_TYPE']

exports Db,Table,Field
