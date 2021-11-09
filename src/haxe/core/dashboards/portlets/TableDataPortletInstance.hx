package core.dashboards.portlets;

import haxe.ui.data.ArrayDataSource;
import haxe.ui.components.Column;
import haxe.ui.containers.Header;
import haxe.ui.containers.TableView;
import core.data.CoreData.TableFragment;
import core.data.Table;

using StringTools;

class TableDataPortletInstance extends PortletInstance {
    private var _table:TableView;
    private var _header:Header = null;

    public function new() {
        super();

        _table = new TableView();
        _table.percentWidth = 100;
        _table.percentHeight = 100;
        _table.virtual = true;
        addComponent(_table);

        /*
        var header = new Header();
        header.percentWidth = 100;

        var col = new Column();
        col.id = "fieldA";
        col.width = 100;
        col.text = "Field A";
        header.addComponent(col);

        var col = new Column();
        col.id = "fieldB";
        col.width = 100;
        col.text = "Field B";
        header.addComponent(col);

        var col = new Column();
        col.id = "fieldC";
        col.width = 100;
        col.text = "Field C";
        header.addComponent(col);

        var col = new Column();
        col.id = "fieldD";
        col.percentWidth = 100;
        col.text = "Field D";
        header.addComponent(col);

        _table.addComponent(header);

        var ds = new ArrayDataSource<Dynamic>();
        for (i in 0...20) {
            ds.add({
                fieldA: "Item " + (i + 1) + "A",
                fieldB: "Item " + (i + 1) + "B",
                fieldC: "Item " + (i + 1) + "C",
                fieldD: "Item " + (i + 1) + "D",
            });
        }
        _table.dataSource = ds;

        _table.onChange = function(_) {
            if (dashboardInstance != null) {
                dashboardInstance.onFilterChanged();
            }
        }
        */
    }

    public override function onDataRefreshed(fragment:TableFragment) {
        if (_header == null) {
            _header = new Header();
            var pcx = 100 / fragment.fieldDefinitions.length;
            _header.percentWidth = 100;
            _table.addComponent(_header);
            for (fd in fragment.fieldDefinitions) {
                var col = new Column();
                col.id = fd.fieldName.replace(" ", "_");
                //col.width = 200;
                col.percentWidth = pcx;
                col.text = fd.fieldName;
                _header.addComponent(col);
            }
        }

        var ds = new ArrayDataSource<Dynamic>();
        for (row in fragment.data) {
            var fieldIndex = 0;
            var item:Dynamic = {};
            for (fd in fragment.fieldDefinitions) {
                Reflect.setField(item, fd.fieldName.replace(" ", "_"), row[fieldIndex]);
                fieldIndex++;
            }

            ds.add(item);
        }

        _table.dataSource = ds;
    }
}