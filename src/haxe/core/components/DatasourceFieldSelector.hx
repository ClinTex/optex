package core.components;

import core.data.internal.CoreData.TableFieldInfo;
import haxe.ui.events.UIEvent;
import core.data.DatabaseManager;
import haxe.ui.data.ArrayDataSource;
import core.data.GenericTable;
import haxe.ui.components.DropDown;
import core.data.DataSourceData;
import core.data.InternalDB;

class DatasourceFieldSelector extends DropDown {
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

    private var _selectedFieldName:String = null;
    public var selectedFieldName(get, set):String;
    private function get_selectedFieldName():String {
        if (this.selectedItem == null) {
            return _selectedFieldName;
        }
        var fd:TableFieldInfo = this.selectedItem.fieldDefinition;
        if (fd == null) {
            return _selectedFieldName;
        }
        _selectedFieldName = fd.fieldName;
        return _selectedFieldName;
    }
    private function set_selectedFieldName(value:String):String {
        _selectedFieldName = value;
        refreshUI();
        return value;
    }

    private var _transformString:String;
    public var transformString(get, set):String;
    private function get_transformString():String {
        return _transformString;
    }
    private function set_transformString(value:String):String {
        _transformString = value;
        refreshUI();
        return value;
    }

    private function refreshUI() {
        if (_selectedDataSource == null) {
            return;
        }
        DatabaseManager.instance.getDatabase(_selectedDataSource.databaseName).then(db -> {
            var table:GenericTable = cast(db.getTable(_selectedDataSource.tableName), GenericTable);
            if (_transformString != null) {
                var context:Map<String, Any> = [];
                table = table.transform(_transformString, context);
            }
            var ds = new ArrayDataSource<Dynamic>();
            for (fd in table.info.fieldDefinitions) {
                ds.add({
                    text: fd.fieldName,
                    fieldDefinition: fd
                });
            }
            this.dataSource = ds;
            this.selectedItem = _selectedFieldName;
        });
    }
    /*
    private var _table:GenericTable = null;
    public var table(get, set):GenericTable;
    private function get_table():GenericTable {
        return _table;
    }
    private function set_table(value:GenericTable):GenericTable {
        _table = value;
        refreshFields();
        return value;
    }

    private function refreshFields() {
        var ds = new ArrayDataSource<Dynamic>();
        for (fd in _table.info.fieldDefinitions) {
            ds.add({
                text: fd.fieldName,
                fieldDefinition: fd
            });
        }
        this.dataSource = ds;
    }
    */
}