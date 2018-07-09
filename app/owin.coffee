owin = require 'owin'

#set OWIN_SQL_CONNECTION_STRING=Data Source=(local);Initial Catalog=Northwind;Integrated Security=True

owin.sql "SELECT * FROM Bookings" , ->
  err ->
    console.error err
  result (data)->
