package views;

import haxe.ui.containers.Box;
import haxe.ui.core.Component;
import haxe.ui.containers.dialogs.Dialog.DialogButton;
import haxe.ui.containers.dialogs.MessageBox.MessageBoxType;
import haxe.ui.containers.dialogs.Dialogs;
import sidebars.ImportDataSourceSidebar;
import js.Syntax;
import components.WorkingIndicator;
import haxe.ui.containers.TableView;
import js.lib.Reflect;
import haxe.ui.events.UIEvent;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.containers.VBox;
import haxe.ui.events.MouseEvent;
import core.data.Database;
import core.data.Table;
import core.data.DatabaseManager;

using StringTools;

@:build(haxe.ui.ComponentBuilder.build("assets/views/data.xml"))
class DataView extends VBox {
    public static var instance:DataView;

    private inline function num(i:Dynamic) {
        return Syntax.code("Number({0})", i);
    }

    public function new() {
        super();
        instance = this;
        refresh();
    }

    private var _databaseToSelect:String = null;
    private var _tableToSelect:String = null;
    public function refresh(selectedDatabase:String = null, selectedTable:String = null) {
        _databaseToSelect = selectedDatabase;
        _tableToSelect = selectedTable;
        DatabaseManager.instance.listDatabases().then(function(dbs) {
            var ds = new ArrayDataSource<Dynamic>();
            var indexToSelect = 0;
            var n = 0;
            for (db in dbs) {
                ds.add({
                    text: db.name,
                    db: db
                });
                if (selectedDatabase != null && db.name == selectedDatabase) {
                    indexToSelect = n;
                }
                n++;
            }
            databaseSelector.dataSource = ds;
            databaseSelector.selectedIndex = -1;
            databaseSelector.selectedIndex = indexToSelect;

            _databaseToSelect = null;
        });
    }

    public function removeCurrentDatabase() {
        var selectedItem = databaseSelector.selectedItem;
        if (selectedItem == null) {
            return;
        }

        var working = new WorkingIndicator();
        working.showWorking();
        DatabaseManager.instance.removeDatabase(selectedItem.db.name).then(function(r) {
            working.workComplete();
            refresh();
        });
    }

    private var _database:Database;
    @:bind(databaseSelector, UIEvent.CHANGE)
    private function onDatabaseSelectorChanged(e:UIEvent) {
        var selectedItem = databaseSelector.selectedItem;
        if (selectedItem == null) {
            return;
        }

        var dbName = selectedItem.db.name;
        _database = new Database(dbName);
        _database.listTables().then(function(tables) {
            var ds = new ArrayDataSource<Dynamic>();
            var indexToSelect = 0;
            var n = 0;
            for (table in tables) {
                ds.add({
                    name: table.name,
                    type: "static",
                    rows: table.getRowCount(),
                    table: table
                });
                if (_tableToSelect != null && _tableToSelect == table.name) {
                    indexToSelect = n;
                }
                n++;
            }

            tableSelector.dataSource = ds;
            tableSelector.selectedIndex = -1;
            tableSelector.selectedIndex = indexToSelect;
            _tableToSelect = null;
        });
    }

    @:bind(tableSelector, UIEvent.CHANGE)
    private function onTableSelectorChange(e:UIEvent) {
        if (tableSelector.selectedItem == null) {
            return;
        }

        var selectedItem = tableSelector.selectedItem;
        refreshTableData(selectedItem.table);
    }

    private function refreshTableData(table:Table) {
        dataSourceDataTable.clearContents(true);

        var colWidths:Map<Component, Float> = [];
        var cols:Map<String, Component> = [];
        var fieldDefs = table.fieldDefinitions;
        var maxCols = 100;
        var n = 0;
        for (fd in fieldDefs) {
            var column = dataSourceDataTable.addColumn(safeId(fd.fieldName));
            column.width = guessStringWidth(column.text);
            colWidths.set(column, column.width);
            cols.set(column.id, column);
            if (n > maxCols) {
                break;
            }
            n++;
        }

        var n = Std.int((dataSourceDataTable.height - 75) / 25);
        table.getRows(0, n).then(function(f) {
            var ds = new ArrayDataSource<Dynamic>();
            for (d in f.data) {
                var fieldIndex = 0;
                var item:Dynamic = {};
                for (fd in fieldDefs) {
                    Reflect.setField(item, safeId(fd.fieldName), d[fieldIndex]);

                    var column = cols.get(safeId(fd.fieldName));
                    var columnWidth = colWidths.get(column);
                    var newWidth = guessStringWidth(Std.string(d[fieldIndex]), 9);
                    if (newWidth > columnWidth) {
                        colWidths.set(column, newWidth);
                    }

                    fieldIndex++;
                }
                ds.add(item);
            }

            for (column in colWidths.keys()) {
                var cx = colWidths.get(column);
                column.width = cx;
            }

            dataSourceDataTable.dataSource = ds;
        });
    }

    private inline function guessStringWidth(s:String, cx:Int = 10) {
        return (s.length * cx) + 20;
    }

    private inline function safeId(fieldName:String) {
        return fieldName.replace("\"", "").replace(" ", "_");
    }

    @:bind(addDataButton, MouseEvent.CLICK)
    private function onAddDataButton(e:MouseEvent) {
        DatabaseManager.instance.listDatabases().then(function(dbs) {
            var sidebar = new ImportDataSourceSidebar();
            sidebar.databases = dbs;
            sidebar.position = "right";
            sidebar.modal = true;
            sidebar.show();
        });
    }

    @:bind(removeDataButton, MouseEvent.CLICK)
    private function onRemoveDataButton(e:MouseEvent) {
        if (tableSelector.selectedItem == null) {
            return;
        }

        var message = "Are you sure you wisth to remove the '" + tableSelector.selectedItem.table.name + "' table?\n\nThis cannot be undone";
        Dialogs.messageBox(message, "Confirm Removal", MessageBoxType.TYPE_QUESTION, function(button) {
            if (button == DialogButton.YES) {
                var working = new WorkingIndicator();
                working.showWorking();
                _database.removeTable(tableSelector.selectedItem.table.name).then(function(r) {
                    working.workComplete();
                    refresh(_database.name);
                });
            }
        });
    }
}
