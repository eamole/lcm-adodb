fs = require 'fs'
sha256 = require "sha256"
mkdirp = require 'mkdirp'

class Cache
  constructor : (@storagePath , @fileExt) ->

  filename : (name) ->
    filename = @storagePath + name + @fileExt   # storagePath has /

  path : ->
    __basedir + "/" + @storagePath  # storagePath has /

  pathExists : ->
    path = @path()
    if not fs.existsSync path
      mkdirp path, (err) ->
        if err console.error err
        else console.log "#{path} created"

# a static filename used to cache the data
class JsonCache extends Cache
  # storagepath : path to where the file should be stored
  # fileName : a static filename to use
  # cbGetData : method call to refresh data
  constructor : (storagePath,@fileName,@cbRefreshData,@onDataAvailable) ->
    super storagePath , ".json"

  onRefresh : (@data) =>  # for db, it'll be a simple array of table names
    try
      @strData = JSON.stringify(@data,null,4)   # write raw text - 4 = PRETTY
      #@lastSha = sha256(data)       # compute sha
      @pathExists()
      fs.writeFileSync @filename(), @strData
      @onDataAvailable @data

    catch e
      console.log "Json Error : cannot encode #{e}"


  getData : (cb) -> #showAll
    if not fs.existsSync @filename() # this is a first call or file doesn't exist
      console.log "Cache [#{@storagePath}]: file [@filename()] not exists - refresh data "
      @cacheRefreshed = true  # reset counter

      # creating a sync block after a sync action
      @cbRefreshData (data) =>
        @onRefresh data
        cb @data

    else  # load from file
      console.log "Cache [#{@storagePath}]: file [@filename()] exists - load data "
      @strData = fs.readFileSync @filename()
      @data = JSON.parse(@strData)
      @cacheRefreshed = false;  # maybe a counter here
      # bind to correct property and process raw data
      @onDataAvailable @data    # do whatever processing required - eg map to property!!
      cb @data  # call immediately

  filename : ->
    fileName = super @fileName


# the client must either save the sha in memory or persist it
# if the server restarts the sha is lost unloess persisted
# and therefore the data is reloaded
class JsonCacheSha extends JsonCache
  # storagepath : path to where the file should be stored
  # lastSha : the sha of the last data - if null, get the data
  # cbGetData : method call to get the live data
  constructor : (storagePath,lastSha,cbGetData) ->
    # this badly needs reworking
    super storagePath,lastSha,cbGetData
    if not @lastSha? or notExists = not fs.existsSync @filename() # this is a first call or file doesn't exist
      console.log "Cache [#{@storagePath}]: first call - no sha - re-read data " if not @lastSha?

module.exports=JsonCache