package core.dashboards.portlets;

import haxe.ui.containers.ListView;
import haxe.ui.components.TextField;
import core.data.CoreData.TableFragment;
import haxe.ui.data.ArrayDataSource;

class ExpandableFilterPortletInstance extends PortletInstance {
    private var _filter:TextField;
    private var _list:ListView;

    public function new() {
        super();

        styleString = "spacing: 0px";

        _filter = new TextField();
        _filter.percentWidth = 100;
        _filter.placeholder = "Type to search in list";
        _filter.styleString = "border-radius: 0; border-bottom: none;";
        addComponent(_filter);

        _list = new ListView();
        _list.virtual = true;
        _list.percentWidth = 100;
        _list.height = 100;
        addComponent(_list);
    }

    public override function onDataRefreshed(fragment:TableFragment) {
        var ds = new ArrayDataSource<Dynamic>();
        var size = fragment.data.length;
        ds.add({
            text: "(All) " + size + " values"
        });
        for (row in fragment.data) {
            ds.add({
                text: row[0]
            });
        }
        _list.dataSource = ds;
    }
}