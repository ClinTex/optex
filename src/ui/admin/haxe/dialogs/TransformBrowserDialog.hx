package dialogs;

import haxe.ui.events.MouseEvent;
import haxe.ui.components.Label;
import haxe.ui.core.Component;
import haxe.ui.events.UIEvent;
import core.data.GenericTable;
import core.data.dao.Database;
import haxe.ui.data.ArrayDataSource;
import core.data.DatabaseManager;
import haxe.ui.containers.dialogs.Dialog;

using StringTools;

@:build(haxe.ui.ComponentBuilder.build("assets/dialogs/transform-browser.xml"))
class TransformBrowserDialog extends Dialog {
    private var _database:Database;
    private var _table:GenericTable;

    private var _footerLabel:Label;

    public function new() {
        super();

        _footerLabel = new Label();
        _footerLabel.verticalAlign = "center";
        addFooterComponent(_footerLabel);
        buttons = DialogButton.CLOSE;
        populateDatabases();
    }

    private function populateDatabases() {
        _database = null;
        _table = null;

        DatabaseManager.instance.listDatabases(false).then(function(dbs) {
            var ds = new ArrayDataSource<Dynamic>();
            var indexToSelect = 0;
            var n = 0;

            for (db in dbs) {
                if (db.name.startsWith("__")) {
                    continue;
                }
                ds.add({
                    text: db.name,
                    db: db
                });
                n++;
            }

            databaseSelector.dataSource = ds;
            databaseSelector.selectedIndex = -1;
            databaseSelector.selectedIndex = indexToSelect;
        });
    }
    
    @:bind(databaseSelector, UIEvent.CHANGE)
    private function onDatabaseSelectorChanged(e:UIEvent) {
        var selectedItem = databaseSelector.selectedItem;
        if (selectedItem == null) {
            return;
        }

        _database = selectedItem.db;
        _table = null;
        _database.listTables().then(function(tables) {
            var ds = new ArrayDataSource<Dynamic>();
            var indexToSelect = 0;
            var n = 0;
            for (table in tables) {
                ds.add({
                    text: table.name,
                    table: table
                });
                n++;
            }

            ds.sort("name");
            tableSelector.dataSource = ds;
            tableSelector.selectedIndex = -1;
            tableSelector.selectedIndex = indexToSelect;
        });
    }

    @:bind(tableSelector, UIEvent.CHANGE)
    private function onTableSelectorChange(e:UIEvent) {
        if (tableSelector.selectedItem == null) {
            return;
        }

        var selectedItem = tableSelector.selectedItem;
        _table = selectedItem.table;
        refreshTableData(selectedItem.table);
    }

    @:bind(example1Button, MouseEvent.CLICK)
    private function onExample1(e:UIEvent) {
        transformListField.text = "group-by('Investigator Site')";
    }

    @:bind(example2Button, MouseEvent.CLICK)
    private function onExample2(e:UIEvent) {
        transformListField.text = "group-by('Investigator Site')\n    ->average('Number Completed Visits')\n    ->average('Data Entry Lag (Days)')\n    ->average('Expected Number of Visits')\n    ->average('Actual Number of Visits')";
    }

    @:bind(example3Button, MouseEvent.CLICK)
    private function onExample3(e:UIEvent) {

    }

    @:bind(applyTransformButton, MouseEvent.CLICK)
    private function onApplyTransform(e:UIEvent) {
        refreshTableData(_table, transformListField.text);
    }

    private function refreshTableData(table:GenericTable, transformList:String = null) {
        resultsTable.clearContents(true);

        table.fetch().then(function(_) {
            table = table.transform(transformList, []);

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
        });
    }

    private inline function guessStringWidth(s:String, cx:Int = 10) {
        return (s.length * cx) + 20;
    }

    private inline function safeId(fieldName:String) {
        return fieldName.replace("\"", "").replace(" ", "_");
    }
}