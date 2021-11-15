package core.dashboards.portlets;

import haxe.ui.containers.ListView;
import haxe.ui.components.TextField;
import core.data.CoreData.TableFragment;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.events.UIEvent;

using StringTools;

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
        _list.registerEvent(UIEvent.CHANGE, onListChange);
        addComponent(_list);
    }

    public override function onFilterChanged(filter:Map<String, Any>) {
        var value = filter.get(_filterFieldName);
        var ds = _list.dataSource;
        var indexToSelect = 0;
        for (i in 0...ds.size) {
            var item = ds.get(i);
            if (item.text == value) {
                indexToSelect = i;
                break;
            }
        }
        _list.selectedIndex = indexToSelect;
    }

    private function onListChange(_) {
        var selectedItem = _list.selectedItem;
        if (selectedItem == null) {
            return;
        }

        var selectedText:String = selectedItem.text;
        var allValues = selectedText.startsWith("(All)");
        if (allValues == true) {
            dashboardInstance.removeFilterItem(_filterFieldName);
        } else {
            dashboardInstance.addFilterItem(_filterFieldName, selectedText);
        }
    }

    private var _filterFieldName:String = null;
    public override function onDataRefreshed(fragment:TableFragment) {
        _filterFieldName = fragment.fieldDefinitions[0].fieldName;

        var indexToSelect = 0;
        var ds = new ArrayDataSource<Dynamic>();
        var size = fragment.data.length;
        for (row in fragment.data) {
            ds.add({
                text: row[0]
            });
        }
        ds.sort();
        ds.insert(0, {
            text: "(All) " + size + " values"
        });
        _list.dataSource = ds;
        _list.selectedIndex = indexToSelect;
    }
}