package core.components.dialogs.transforms;

import haxe.ui.core.IDataComponent;
import haxe.ui.containers.dialogs.Dialog;
import core.components.portlets.PortletDataUtils;
import core.data.DataSourceData;
import haxe.ui.data.ArrayDataSource;

using StringTools;

class TransformConfigDialog extends Dialog {
    private var _selectedDataSource:DataSourceData = null;
    public var selectedDataSource(get, set):DataSourceData;
    private function get_selectedDataSource():DataSourceData {
        return _selectedDataSource;
    }
    private function set_selectedDataSource(value:DataSourceData):DataSourceData {
        _selectedDataSource = value;
        return value;
    }

    private function buildDataSourceFieldListFor(component:IDataComponent) {
        PortletDataUtils.fetchTableData(_selectedDataSource.databaseName, _selectedDataSource.tableName).then(function(table) {
            var ds = new ArrayDataSource<Dynamic>();
            for (fd in table.info.fieldDefinitions) {
                ds.add({
                    text: fd.fieldName,
                    fieldName: fd.fieldName
                });
            }
            component.dataSource = ds;
        });
    }

    private var _transformParams:Array<String> = [];
    public var transformParams(get, set):Array<String>;
    private function get_transformParams():Array<String> {
        return _transformParams;
    }
    private function set_transformParams(value:Array<String>):Array<String> {
        _transformParams = value;
        return value;
    }

    public var humanReadableTransformParams(get, null):String;
    private function get_humanReadableTransformParams():String {
        if (_transformParams == null) {
            return "";
        }

        return _transformParams.join(" and ").replace("'", "").replace("$", "");
    }

}