package core.components;

import haxe.ui.events.UIEvent;
import core.data.DataSourceData;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.components.DropDown;
import haxe.ui.containers.HBox;
import core.data.InternalDB;

class DatasourceSelector extends HBox {
    private var _databaseSelector:DropDown;
    private var _tableSelector:DropDown;
    
    private var _datasourceMap:Map<String, Array<DataSourceData>> = [];

    public function new() {
        super();

        _databaseSelector = new DropDown();
        _databaseSelector.percentWidth = 50;
        _databaseSelector.onChange = function(_) {
            refreshTables();
        }
        addComponent(_databaseSelector);

        _tableSelector = new DropDown();
        _tableSelector.percentWidth = 50;
        _tableSelector.onChange = function(_) {
            if (_tableSelector.selectedItem == null) {
                return;
            }
            selectedDataSource = _tableSelector.selectedItem.dataSource;
            var event = new UIEvent(UIEvent.CHANGE);
            this.dispatch(event);
        }
        addComponent(_tableSelector);

        refreshDatasourceMap();
    }

    private var _selectedDataSource:DataSourceData = null;
    public var selectedDataSource(get, set):DataSourceData;
    private function get_selectedDataSource():DataSourceData {
        return _selectedDataSource;
    }
    private function set_selectedDataSource(value:DataSourceData):DataSourceData {
        _selectedDataSource = value;
        refreshUI();
        return value;
    }

    private override function onReady() {
        super.onReady();
        refreshUI();
        /*
        if (selectedDataSource != null) {
            _databaseSelector.selectedItem = selectedDataSource.databaseName;
            _tableSelector.selectedItem = selectedDataSource.tableName;
        }
        */
    }

    private function refreshDatasourceMap() {
        _datasourceMap = [];
        for (ds in InternalDB.dataSources.data) {
            var item = _datasourceMap.get(ds.databaseName);
            if (item == null) {
                item = [];
                _datasourceMap.set(ds.databaseName, item);
            }

            item.push(ds);
        }
    }

    private function refreshUI() {
        refreshDatabases();
    }

    private function refreshDatabases() {
        var indexToSelect = 0;
        var ds = new ArrayDataSource<Dynamic>();
        var n = 0;
        for (databaseName in _datasourceMap.keys()) {
            if (selectedDataSource != null && selectedDataSource.databaseName == databaseName) {
                indexToSelect = n;
            }
            ds.add({
                text: databaseName
            });
            n++;
        }
        _databaseSelector.dataSource = ds;
        _databaseSelector.selectedIndex = indexToSelect;
        refreshTables();
    }

    private function refreshTables() {
        if (_databaseSelector.selectedItem == null) {
            return;
        }
        var selectedDatabase = _databaseSelector.selectedItem.text;

        var datasourceList = _datasourceMap.get(selectedDatabase);
        if (datasourceList == null) {
            return;
        }
        var indexToSelect = 0;
        var n = 0;
        var ds = new ArrayDataSource<Dynamic>();
        for (d in datasourceList) {
            if (selectedDataSource != null && selectedDataSource.tableName == d.tableName) {
                indexToSelect = n;
            }
            ds.add({
                text: d.tableName,
                dataSource: d
            });
            n++;
        }
        _tableSelector.dataSource = ds;
        _tableSelector.selectedIndex = indexToSelect;
    }
}