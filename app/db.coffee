ADODB = require './adodb'    # require('node-adodb');
{JsonCache,pathExists,writeFile} = require "./utils"
fs = require 'fs-extra'

#Provider=Microsoft.ACE.OLEDB.12.0;Data Source=E:\ResMgr\amdex\resmanager;Jet OLEDB:Database Password=AERLINGUS

table_id = 0; # used to generate table ids

promise = (fn) ->
  new Promise (resolve,reject) ->
    try
      resolve fn()
    catch e
      reject e

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
    @storagePath = "storage/db/#{@name}/"
    pathExists @storagePath
    @passString = ""
    @passString = "Jet OLEDB:Database Password=#{@password}" if @password?
    @file = @path + @ext
    @provider = 'Provider=Microsoft.ACE.OLEDB.12.0'
    @dataSource = "Data Source=#{@file}"
    @connected = false;
    # the cache should really be bound to a method or property/getter - later
    @cacheTables = new JsonCache @storagePath, "adodb-table-list" , @adodbGetTables , @adodbTablesReceived
    @cacheFields = new JsonCache @storagePath, "tables" , @adodbGetFields , @adodbFieldsReceived
    @tables={}


  connect : ->
    cnnString = "#{@provider};#{@dataSource};#{@passString}"
    @cnn = ADODB.open cnnString
    @connected=true;

  query : (sql) ->
    @connect() if not @connected
    data = @cnn.query(sql)
    data

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

  # should rewrite this using promises
  getFields : () =>      #showAll     # fat - used as a static callback
    # use the cache
    if @fields
      return Promise.resolve @fields
    else
      @cacheFields.getData()  #showAll

  adodbFieldsReceived : (tables) =>  # @ in promise/cb - should really use the rawFieldlist here
      console.log "convert json data to table/field objects"
      # this called after the cache has been read AND after the data has been received from adodb
      # process the json data
      for k,v of tables   # its an object not array
        Table.fromJson(@,v)

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
    @cnn.schema 4 , [null,null,null]
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
#    @tables[name] = table
    table

class Table
  #statics
  @filenameData : "data.json"
  @filenameMetadata : "metadata.json"
  constructor : (@db,@name) ->
    @id = ++table_id if not @id
    @primaryKey = "" if not @primaryKey
    @fields={}
    @db.tables[@name]=@
    @count = 0
    @storagePath = @db.storagePath + "#{@name}/"
    pathExists @storagePath
    fields=[] # temp holder ousteide scope
    fs.exists @storagePath + Table.filenameMetadata , (exists) =>
      if exists
        @unpersistMetadata()
# only needed if metadata changes
#          .then =>
#            fields = Object.values(@fields)
#            fields.sort (a,b) ->
#              a.ord - b.ord
#          .then =>
#            #convert array back to object
#            @fields = {}  # reset
#            for field in fields
#              @fields[field.name]=field
#          .then =>
#            @persistMetadata()

  meta : ->
    #only needed if metadata changes
    fields = Object.values(@fields)
    fields.sort (a,b) ->
      a.ord - b.ord
    #convert array back to object
    @fields = {}  # reset
    for field in fields
      @fields[field.name]=field
    @persistMetadata()



  # this is largely redundant
  @fromJson : (db , tableJson) ->
    console.log "Dint forget to get rid of static Table.fromJson being used to load from fields file "
    table = db.addTable(tableJson.name)
  #    table.count = tableJson.count if tableJson.count?
    for k,fieldJson of tableJson.fields   # obj not array
      Field.fromJson(table,fieldJson)

  # restore this object
  _fromJson : (json) ->
    @id = json.id if json.id?
    @name = json.name
    @primaryKey = json.primaryKey if json.primaryKey?
    @count = json.count
    @fields = json.fields

  toJSON : (key) => # fat @
    if key?
      id : @id
      name : @name
      primaryKey : @primaryKey
      count : @count
      fields : @fields
    else
      @


  dump : ->
    console.log "Hello from table #{@name}"

  # lets try code this with a promise!! - adodb returns promise
  adodbGetCount : ->
    @db.query("SELECT count(*) as count FROM #{@name};")
      .then (data) =>
      # adodb returns funny structure for expressions such as count
        @count = data[0].Expr1000  # its an array with 1 value
        console.log "Record count #{@name} : #{@count}"
      .catch (err) =>
        console.log "Table.getCount()",err

  # reads data into cache
  adodbGetData : ->
    @db.query "SELECT * FROM #{@name};"
      .then (@data) =>
#        @data = []  # this will probably be a keyed object, once I've set the keys
#        for k,row in data
#          @data.push data
      .then => # fat @
        @count = @data.length
        @persistMetadata()
      .then =>  # fat @
        @persistData()

  adodbGetFields : ->
    @db.cnn.schema 4 , [null,null,@name]
      .then (@schema) =>  # fat for @ in promise
        for column in @schema
          @addField column
      .catch (e) ->
        console.log "getFields Error : #{e}"

  addAdodbField : (ado) ->
    field = Field.fromAdodb @,ado
#    @fields[field.name]=field
    field

  unpersistMetadata : ->
    filename = @storagePath + Table.filenameMetadata
    fs.exists(filename)
      .then (exists) =>
        fs.readFile(filename)
          .then (data) =>
            json = JSON.parse(data)
            @_fromJson json

  unpersistData : ->
    filename = @storagePath + Table.filenameData
    fs.exists(filename)
      .then (exists) =>
        fs.readFile(filename)
          .then (data) =>
            @data = JSON.parse(data)

  # saves the table meta data
  persistData  : ->
    data = JSON.stringify(@data,null,2)
    writeFile @storagePath , Table.filenameData, data

  # save meta
  persistMetadata : ->
    data = JSON.stringify(@,null,2)
    promise =>
      writeFile @storagePath , Table.filenameMetadata , data


  getData : ->
    if @data
      Promise.resolve @data
    else
      filename = @storagePath + Table.filenameData
      fs.exists(filename)
        .then (exists) =>
          if exists
            @unpersistData()
          else
            @adodbGetData()


class Field
  @types : {}
  constructor : (@table,@name) ->
    @table.fields[@name] = @

  # static
  @fromAdodb : (table,ado) ->
    try
      name = @ado['COLUMN_NAME']

      f = new Field(table,name)

      f.itype = ado['DATA_TYPE']
      f.type = Field.types[f.itype]
      f.ord = ado['ORDINAL_POSITION']
      f.size = ado['CHARACTER_MAXIMUM_LENGTH'] || ado['NUMERIC_PRECISION']
      f.nullable = ado['IS_NULLABLE']
      f.hasDefault = ado['COLUMN_HAS_DEFAULT']
      f.default = ado['COLUMN_DEFAULT']

    catch e
      console.log "Field Error : #{e}"
    f # return

  @fromJson : (table,fieldJson) ->
    f = new Field table , fieldJson.name
    # i don't think any special processing is required
    f = Object.assign(f,fieldJson)
#    table.fields[fieldJson.name] = f
    f

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
