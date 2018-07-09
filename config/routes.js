// Draw routes.  Locomotive's router provides expressive syntax for drawing
// routes, including support for resourceful routes, namespaces, and nesting.
// MVC routes can be mapped to controllers using convenient
// `controller#action` shorthand.  Standard middleware in the form of
// `function(req, res, next)` is also fully supported.  Consult the Locomotive
// Guide on [routing](http://locomotivejs.org/guide/routing.html) for additional
// information.
module.exports = function routes() {
  this.root('pages#main');
  this.match("/tables" , "tables#index");
  this.match("/tables/read/:name" , "tables#read");
  this.match("/tables/show/:name" , "tables#show");
  this.match("/tables/scan/:name" , "tables#scan");
  this.match("/tables/count/:name" , "tables#count");
  this.match("/tables/meta/:name" , "tables#meta");
  this.match("/tables/inserts/:name" , "tables#inserts");
  this.match("/tables/getRecordCounts" , "tables#countAll");



}
