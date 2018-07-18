# a node/backbone implementation
# problem is backbone runs on the client, and I want some form of server side control
# the backbone view may be a problems - must be rendered on the client, but generated on the server
# this needs to generate stuff for inclusion in the template
# maybe add some template helper functions
# this should probably create a crud routing as well
# might even generate static front end controllers, views and models
jade = require 'jade'

class Backbone
  constructor : (@name) ->  # the MVC name, model and view
    @model = @name

  # need to do an inital render
  # controller - this is the locomotive controller - need to add stuff to controller object
  # view - name of jade file - should default to current action ala loco
  render : (controller,view) ->
    # need to insert the Models, Collection (maybe) and View(s)

module.exports = new Backbone