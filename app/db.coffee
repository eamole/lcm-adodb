ADODB = require('node-adodb');
JsonCache = require "./utils"

# ADO constants
adodb =
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
    integer : 3     # default number/autonumber 10 places
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
    wchar : 130   # unicode string



class Db
  constructor : (@name,@path,@password,@ext=".mdb") ->
    @passString = ""
    @passString = "Jet OLEDB:Database Password=#{@password}" if @password?
    @file = @path + @ext
    @provider = 'Provider=Microsoft.ACE.OLEDB.12.0'
    @dataSource = "Data Source=#{@file}"
    @connected = false;
    # the cache should really be bound to a method or property/getter - later
    @cacheTables = new JsonCache "storage/db/#{@name}/" , "adodb-table-list" , @adodbGetTables , @adodbTablesReceived
    @cacheFields = new JsonCache "storage/db/#{@name}/" , "tables" , @adodbGetFields , @adodbFieldsReceived

  connect : ->
    cnnString = "#{@provider};#{@dataSource};#{@passString}"
    @cnn = ADODB.open cnnString
    @connected=true;

  getTable : (name) ->
    console.log "table [#{name} not found in database.tables" if not @tables[name]?
    table = @tables[name]

    # actually already have the data below!! but should really allow the cache to play with it before using it
  adodbTablesReceived : (@tableList) =>  # @ in promise/cb
    # this is not indexed!
    #    @tables = @tableList.map (tableName) => # @ inside cb
    #      new Table(@,tableName)
    @tables = {}
    for tablename in @tableList
      table = new Table @,tablename
      @tables[tablename]=table


  adodbGetTables : (cb) =>
    @connect() if not @connected
    @cnn.schema 20
      .then (@schema) =>  # fat for @ in promise
        @tableList = @schema.map (adoRec) -> adoRec['TABLE_NAME']
        # @adodbTablesReceived @tableList // cyclic will be called below - why specify separately???
        # will be called after cache has been saved
        cb @tableList    # cache.onRefresh + showAll!!
      .catch (e) ->
        console.log "adodbGetTables Error : #{e} "

# kludge - should return a promise!! - instead using a callback!! needs to be bound
  getTables : (cb) =>      #showAll     # fat - used as a static callback
## use the cache
    if @tables
      cb @tables
    else
      @cacheTables.getData(cb)  #showAll

  getFields : (cb) =>      #showAll     # fat - used as a static callback
## use the cache
    if @fields
      cb @fields
    else
      @cacheFields.getData(cb)  #showAll

  adodbFieldsReceived : (@tables) =>  # @ in promise/cb - should really use the rawFieldlist here
      console.log "why here"
  adodbGetFields : (cb) =>
    @connect() if not @connected
    @cnn.schema 4 # , [null,null,null]   # get ALL fields in db
      .then (@schema) =>  # fat for @ in promise
        tableList = @schema.map (ado)->
          ado['TABLE_NAME']
        @tableList = [...new Set(tableList)]  # unique tables as list
        # construct the @tables
        for ado in @schema
          tableName = ado['TABLE_NAME']
          # check if already exists
          @tables={} if not @tables?
          table = @addTable tableName if not @tables[tableName]?
          table = @tables[tableName]
          table.addField ado
        cb @tables    # cache.onRefresh + showAll!!
      .catch (e) ->
        console.log "adodbGetFields Error : #{e} "

# single query retuirns all fields, which give you all tables as well
  xgetFields : (cb) ->
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
    @fields={}

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

  toJSON : (key) => # fat @
    if key?
      name : @name
      fields : @fields
    else
      @



class Field
  @types : {}
  constructor : (@table,@ado) ->

    try
      @name = @ado['COLUMN_NAME']
      @itype = @ado['DATA_TYPE']
      @type = Field.types[@itype]
      @ord = @ado['ORDINAL_POSITION']
      @size = @ado['CHARACTER_MAXIMUM_LENGTH'] || @ado['NUMERIC_PRECISION']
      @nullable = @ado['IS_NULLABLE']
      @hasDefault = @ado['COLUMN_HAS_DEFAULT']
      @default = @ado['COLUMN_DEFAULT']

    catch e
      console.log "Field Error : #{e}"
  # static
  @getTypes : ->
    # invert the enums above
    for value,key of adodb.typeEnum
      @types[key]=value

  toJSON : (key) =>
    # need to remove backpointer table!!
    name : @name
    itype : @itype
    type : @type
    ord : @ord
    size : @size
    nullable : @nullable
    hasDefault : @hasDefault
    default : @default

#    o={}
#    for v,k of @
#      o[k] = v if k not in ["table","ado"]
#    o
# static call
Field.getTypes()

module.exports = Db
