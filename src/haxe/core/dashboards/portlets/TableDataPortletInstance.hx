package core.dashboards.portlets;

import core.data.GenericTable;
import haxe.ui.events.UIEvent;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.components.Column;
import haxe.ui.containers.Header;
import haxe.ui.containers.TableView;

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
        _table.registerEvent(UIEvent.CHANGE, onTableSelectionChanged);
        addComponent(_table);
    }

    private var _previousTableSelectedIndex = -1;
    private function onTableSelectionChanged(_) {
        var selectedItem = _table.selectedItem;
        if (selectedItem == null) {
            return;
        }

        var field = "Investigator Site";

        if (_previousTableSelectedIndex != -1 && _table.selectedIndex == _previousTableSelectedIndex) {
            _previousTableSelectedIndex = -1;
            _table.selectedIndex = -1;
            dashboardInstance.removeFilterItem(field);
            return;
        }

        _previousTableSelectedIndex = _table.selectedIndex;

        var safeField = field.replace(" ", "_");
        var value = Reflect.field(selectedItem, safeField);
        dashboardInstance.addFilterItem(field, value);
        trace(selectedItem);
    }

    public override function onFilterChanged(filter:Map<String, Any>) {
        var ds = _table.dataSource;
        ds.clearFilter();
        ds.filter(function(index, item) {
            var use = true;
            for (key in filter.keys()) {
                var filterValue = filter.get(key);
                var safeKey = key.replace(" ", "_");
                var value = Reflect.field(item, safeKey);
                if (value != filterValue) {
                    use = false;
                }
            }
            return use;
        });
    }

    public override function onDataRefreshed(table:GenericTable) {
        if (_header == null) {
            _header = new Header();
            var pcx = 100 / table.info.fieldDefinitions.length;
            _header.percentWidth = 100;
            _table.addComponent(_header);
            for (fd in table.info.fieldDefinitions) {
                var col = new Column();
                col.id = fd.fieldName.replace(" ", "_");
                //col.width = 200;
                col.percentWidth = pcx;
                col.text = fd.fieldName;
                _header.addComponent(col);
            }
        }

        var ds = new ArrayDataSource<Dynamic>();
        for (row in table.records) {
            var fieldIndex = 0;
            var item:Dynamic = {};
            for (fd in table.info.fieldDefinitions) {
                Reflect.setField(item, fd.fieldName.replace(" ", "_"), row.getFieldValue(fd.fieldName));
                fieldIndex++;
            }

            ds.add(item);
        }

        _table.dataSource = ds;
    }
}