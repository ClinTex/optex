package core.components.dialogs.transforms;

import haxe.ui.containers.dialogs.Dialog;
import core.data.DataSourceData;
import core.components.portlets.PortletDataUtils;
import haxe.ui.components.Label;
import haxe.ui.core.Component;
import core.data.GenericTable;
import haxe.ui.data.ArrayDataSource;

using StringTools;

@:build(haxe.ui.ComponentBuilder.build("core/assets/ui/dialogs/transforms/transform-results-preview.xml"))
class TransformResultsPreviewDialog extends Dialog {
    private var _footerLabel:Label;

    public function new() {
        super();
        buttons = DialogButton.CLOSE;
        _footerLabel = new Label();
        _footerLabel.verticalAlign = "center";
        addFooterComponent(_footerLabel);
    }

    private override function onReady() {
        super.onReady();
        refreshResults();
    }

    private function refreshResults() {
        if (_selectedDataSource == null) {
            return;
        }

        PortletDataUtils.fetchTableData(_selectedDataSource.databaseName, _selectedDataSource.tableName).then(function(unfilteredTable) {
            if (_transformString != null) {
                unfilteredTable = unfilteredTable.transform(_transformString , null);
            }
            populateTableData(unfilteredTable);
        });
    }

    private function populateTableData(table:GenericTable) {
        var colWidths:Map<Component, Float> = [];
        var cols:Map<String, Component> = [];
        var fieldDefs = table.info.fieldDefinitions;
        var maxCols = 9;
        var n = 0;
        for (fd in fieldDefs) {
            var column = resultsTable.addColumn(safeId(fd.fieldName));
            column.width = guessStringWidth(column.text);
            colWidths.set(column, column.width);
            cols.set(column.id, column);
            if (n > maxCols) {
                break;
            }
            n++;
        }

        var ds = new ArrayDataSource<Dynamic>();
        for (d in table.records) {
            var item:Dynamic = {};
            n = 0;
            for (fd in fieldDefs) {
                Reflect.setField(item, safeId(fd.fieldName), d.getFieldValue(fd.fieldName));

                var column = cols.get(safeId(fd.fieldName));
                var columnWidth = colWidths.get(column);
                var newWidth = guessStringWidth(Std.string(d.getFieldValue(fd.fieldName)), 9);
                if (newWidth > columnWidth) {
                    colWidths.set(column, newWidth);
                }

                if (n > maxCols) {
                    break;
                }
                n++;
    
            }
            ds.add(item);
        }

        for (column in colWidths.keys()) {
            var cx = colWidths.get(column);
            column.width = cx;
        }

        resultsTable.dataSource = ds;

        _footerLabel.text = table.records.length + " record(s)";
    }

    private inline function guessStringWidth(s:String, cx:Int = 10) {
        return (s.length * cx) + 20;
    }

    private inline function safeId(fieldName:String) {
        return fieldName.replace("\"", "").replace(" ", "_");
    }

    private var _selectedDataSource:DataSourceData = null;
    public var selectedDataSource(get, set):DataSourceData;
    private function get_selectedDataSource():DataSourceData {
        return _selectedDataSource;
    }
    private function set_selectedDataSource(value:DataSourceData):DataSourceData {
        _selectedDataSource = value;
        return value;
    }

    private var _transformString:String;
    public var transformString(get, set):String;
    private function get_transformString():String {
        return _transformString;
    }
    private function set_transformString(value:String):String {
        _transformString = value;
        if (_transformString != null) {
            transformStringLabel.text = _transformString;
        }
        return value;
    }
}