edge = require 'edge-js'

#`
#    func = edge.func( 'sql' , function() { /*
#      select * from bookings;
#*/
#    })
#`

`
  var method = edge.func({
      assemblyFile : '../../ConsoleApp2/ConsoleApp2/bin/Debug/Adodb.dll' ,
      // typeNme : 'Adodb.Ado;db',
      methodName : 'Inserts'
  });

  var payload = {
      table : 'Bookings',
      table_id : '34' ,
      primary_key : 'ref'
  }
`


method payload , ( err , data ) ->
  if err
    console.error err
  else
    for rec in data
      console.log rec
