Backbone = require 'backbone'



class Table extends Backbone.Model
  constructor : ->
    super()
    @bind "change" , @onChange

  onChange : =>


class Tables extends Backbone.Collection
  constructor : ->
    super()
    @model = Table


class TablesView extends Backbone.View
  constructor : ->
    super()
    @el = $ "#table-id"



class TableView extends Backbone.View
  constructor : ->
    super()
    @el = $()


