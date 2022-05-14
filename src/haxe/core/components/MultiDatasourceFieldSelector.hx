package core.components;

import haxe.ui.components.Button;
import haxe.ui.containers.HBox;
import haxe.ui.containers.VBox;
import core.data.DataSourceData;

using StringTools;

class MultiDatasourceFieldSelector extends VBox {
    private override function onReady() {
        super.onReady();
        if (findComponents(DatasourceFieldSelector).length == 0) {
            addFieldSelector();
        }
    }

    private var _selectedDataSource:DataSourceData = null;
    public var selectedDataSource(get, set):DataSourceData;
    private function get_selectedDataSource():DataSourceData {
        return _selectedDataSource;
    }
    private function set_selectedDataSource(value:DataSourceData):DataSourceData {
        _selectedDataSource = value;
        for (c in findComponents(DatasourceFieldSelector)) {
            c.selectedDataSource = _selectedDataSource;
        }
        //refreshUI();
        return value;
    }

    private var _selectedFieldName:String = null;
    public var selectedFieldName(get, set):String;
    private function get_selectedFieldName():String {
        return _selectedFieldName;
    }
    private function set_selectedFieldName(value:String):String {
        var fields = value.split(",");
        for (f in fields) {
            f = f.trim();
            addFieldSelector(f);
        }
        _selectedFieldName = value;
        return value;
    }

    private var _transformString:String;
    public var transformString(get, set):String;
    private function get_transformString():String {
        return _transformString;
    }
    private function set_transformString(value:String):String {
        _transformString = value;
        for (c in findComponents(DatasourceFieldSelector)) {
            c.transformString = _transformString;
        }
        return value;
    }

    private function addFieldSelector(fieldName:String = null) {
        var hbox = new HBox();
        hbox.percentWidth = 100;

        var selector = new DatasourceFieldSelector();
        selector.percentWidth = 100;
        selector.selectedDataSource = _selectedDataSource;
        selector.selectedFieldName = fieldName;
        selector.transformString = _transformString;
        hbox.addComponent(selector);

        var removeButton = new Button();
        removeButton.text = "-";
        hbox.addComponent(removeButton);
        removeButton.onClick = function(e) {
        }

        var addButton = new Button();
        addButton.text = "+";
        addButton.onClick = function(_) {
            addFieldSelector();
        }

        hbox.addComponent(addButton);
        addComponent(hbox);
    }
}