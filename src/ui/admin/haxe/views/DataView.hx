package views;

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
import core.data.dao.Database;
import core.data.DatabaseManager;
import core.data.GenericTable;

using StringTools;

@:build(haxe.ui.ComponentBuilder.build("assets/views/data.xml"))
class DataView extends VBox {
    public static var instance:DataView;

    private var _database:Database;
    private var _table:GenericTable;

    public function new() {
        super();
        instance = this;
        DatabaseManager.instance.listen(DatabaseEvent.Initialized, function(_) {
            refresh("__optex_data");
        });
    }

    private var _databaseToSelect:String = null;
    private var _tableToSelect:String = null;
    private var _showInternalDatabases:Bool = true;
    public function refresh(selectedDatabase:String = null, selectedTable:String = null) {
        _databaseToSelect = selectedDatabase;
        _tableToSelect = selectedTable;

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
                if (selectedDatabase != null && db.name == selectedDatabase) {
                    indexToSelect = n;
                }
                n++;
            }

            ds.sort("text");

            if (_showInternalDatabases) {
                for (db in dbs) {
                    if (!db.name.startsWith("__")) {
                        continue;
                    }
                    ds.add({
                        text: db.name,
                        db: db
                    });
                    if (selectedDatabase != null && db.name == selectedDatabase) {
                        indexToSelect = n;
                    }
                    n++;
                }
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
        _database.remove().then(function(r) {
            working.workComplete();
            refresh();
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
                    name: table.name,
                    type: "static",
                    rows: table.recordCount,
                    table: table
                });
                if (_tableToSelect != null && _tableToSelect == table.name) {
                    indexToSelect = n;
                }
                n++;
            }

            ds.sort("name");
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
        _table = selectedItem.table;
        refreshTableData(selectedItem.table);
    }

    private function refreshTableData(table:GenericTable) {
        dataSourceDataTable.clearContents(true);

        var colWidths:Map<Component, Float> = [];
        var cols:Map<String, Component> = [];
        var fieldDefs = table.info.fieldDefinitions;
        var maxCols = 9;
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

        n = 0;
        table.fetch().then(function(data) {
            var ds = new ArrayDataSource<Dynamic>();
            for (d in data) {
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

        var message = "Are you sure you wisth to remove the '" + tableSelector.selectedItem.table.name + "' table?\n\nThis cannot be undone.\n\n";
        Dialogs.messageBox(message, "Confirm Removal", MessageBoxType.TYPE_QUESTION, function(button) {
            if (button == DialogButton.YES) {
                var working = new WorkingIndicator();
                working.showWorking();
                _table.remove().then(function(r) {
                    working.workComplete();
                    refresh(_database.name);
                });
            }
        });
    }

    private inline function num(i:Dynamic) {
        return Syntax.code("Number({0})", i);
    }
}
