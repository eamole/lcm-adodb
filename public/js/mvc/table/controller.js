// Generated by CoffeeScript 2.3.1
(function() {
  var Backbone, Table, TableView, Tables, TablesView,
    boundMethodCheck = function(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new Error('Bound instance method accessed before binding'); } };

  Backbone = require('backbone');

  Table = class Table extends Backbone.Model {
    constructor() {
      super();
      this.onChange = this.onChange.bind(this);
      this.bind("change", this.onChange);
    }

    onChange() {
      boundMethodCheck(this, Table);
    }

  };

  Tables = class Tables extends Backbone.Collection {
    constructor() {
      super();
      this.model = Table;
    }

  };

  TablesView = class TablesView extends Backbone.View {
    constructor() {
      super();
      this.el = $("#table-id");
    }

  };

  TableView = class TableView extends Backbone.View {
    constructor() {
      super();
      this.el = $();
    }

  };

}).call(this);

//# sourceMappingURL=controller.js.map
