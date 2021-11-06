package core.dashboards.portlets;

import haxe.ui.data.ArrayDataSource;
import haxe.ui.components.Column;
import haxe.ui.containers.Header;
import haxe.ui.containers.TableView;

class TableDataPortletInstance extends PortletInstance {
    public function new() {
        super();

        var table = new TableView();
        table.percentWidth = 100;
        table.percentHeight = 100;
        addComponent(table);

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

        table.addComponent(header);

        var ds = new ArrayDataSource<Dynamic>();
        for (i in 0...20) {
            ds.add({
                fieldA: "Item " + (i + 1) + "A",
                fieldB: "Item " + (i + 1) + "B",
                fieldC: "Item " + (i + 1) + "C",
                fieldD: "Item " + (i + 1) + "D",
            });
        }
        table.dataSource = ds;

        table.onChange = function(_) {
            if (dashboardInstance != null) {
                dashboardInstance.onFilterChanged();
            }
        }
    }
}