fs = require 'fs'

class Cache
  constructor @storagePath , @fileExt

  filename : (name) ->
    filename = @storagePath + "/" + name + @fileExt

# a static filename used to cache the data
class JsonCache extends Cache
  # storagepath : path to where the file should be stored
  # fileName : a static filename to use
  # cbGetData : method call to get the live data
  constructor : (storagePath,@fileName,@cbGetData) ->
    super storagePath , ".json"
    if not fs.existsSync @filename() # this is a first call or file doesn't exist
      console.log "Cache [#{@storagePath}]: file [@filename()] not exists - re-read data "
      @data = cbGetData(@onRefresh)         ## assume sync!! - or provide cb

    else  # load from file
      @strData = fs.readFileSync @filename()
      @data = JSON.parse(str)

  onRefresh : =>
    @strData = JSON.stringify(@data)   # read raw text
    @lastSha = sha256(data)       # compute sha
    fs.writeFileSync @filename(), str

  filename : ->
    fileName = super @fileName


# the client must either save the sha in memory or persist it
# if the server restarts the sha is lost unloess persisted
# and therefore the data is reloaded
class JsonCacheSha extends Jsoncache
  # storagepath : path to where the file should be stored
  # lastSha : the sha of the last data - if null, get the data
  # cbGetData : method call to get the live data
  constructor : (storagePath,lastSha,cbGetData) ->
    # this badly needs reworking
    super storagePath,lastSha,cbGetData
    if not @lastSha? or notExists = not fs.existsSync @filename() # this is a first call or file doesn't exist
      console.log "Cache [#{@storagePath}]: first call - no sha - re-read data " if not @lastSha?
