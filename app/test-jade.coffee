jade = require 'jade'

temp = jade.compileClient '''
h1 This is a title
h2= name
h3 #{name}
table
  each row in data
    tr
      each col in row
        td= col
''' , {
  pretty : true
  debug : true
  compileDebug : true
}


data = {
  name : "Eamonn"
  data : [
    {skill : "Node" , lebel : "Low"} ,
    {skill : "JS" , level : "Lower"}
  ]
}

html = temp(data)
console.log html
