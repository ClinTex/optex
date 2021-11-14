package sidebars;

import core.data.Table;
import core.data.DatabaseManager;
import views.DataView;
import core.data.CoreData.FieldType;
import components.WorkingIndicator;
import haxe.ui.events.MouseEvent;
import core.data.Database;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.events.UIEvent;
import haxe.ui.containers.SideBar;
import core.data.parsers.DataParser;
import core.data.parsers.CSVDataParser;

@:build(haxe.ui.ComponentBuilder.build("assets/sidebars/import-datasource.xml"))
class ImportDataSourceSidebar extends SideBar {
    private var _parser:DataParser;

    public function new() {
        super();
    }

    private var _databases:Array<Database> = [];
    public var databases(null, set):Array<Database>;
    private function set_databases(value:Array<Database>):Array<Database> {
        _databases = value;
        populateDatabases();
        return value;
    }

    private function populateDatabases() {
        var ds = new ArrayDataSource<Dynamic>();
        for (db in _databases) {
            ds.add({
                text: db.name,
                db: db
            });
        }
        existingCoreSelector.dataSource = ds;
        if (ds.size == 0) {
            addToExistingCoreOption.hide();
            existingCoreSelector.hide();
        } else {
            existingCoreSelector.selectedIndex = 0;
            addToExistingCoreOption.show();
            existingCoreSelector.show();
        }
    }

    @:bind(existingCoreSelector, UIEvent.CHANGE)
    private function onExistingCoreSelectorChanged(e:UIEvent) {
        var selectedItem = existingCoreSelector.selectedItem;
        if (selectedItem == null) {
            return;
        }

        var db = selectedItem.db;
        populateTables(db);
    }

    private function populateTables(database:Database) {
        database.listTables().then(function(tables) {
            var ds = new ArrayDataSource<Dynamic>();
            for (table in tables) {
                ds.add({
                    text: table.name + " (" + table.getRowCount() + " records)",
                    table: table
                });
            }
            existingTableSelector.dataSource = ds;
            if (ds.size == 0) {
                addToExistingTableOption.hide();
                existingTableSelector.hide();
            } else {
                existingTableSelector.selectedIndex = -1;
                existingTableSelector.selectedIndex = 0;
    
                if (addToExistingCoreOption.selected == true) {
                    addToExistingTableOption.show();
                    existingTableSelector.show();
                }
            }
        });
    }

    @:bind(createNewCoreOption, UIEvent.CHANGE)
    @:bind(addToExistingCoreOption, UIEvent.CHANGE)
    private function onCreateCoreChanged(e:UIEvent) {
        if (createNewCoreOption.selected == true) {
            newCoreName.disabled = false;
            existingCoreSelector.disabled = true;

            addToExistingTableOption.hide();
            existingTableSelector.hide();
        } else if (addToExistingCoreOption.selected == true) {
            newCoreName.disabled = true;
            existingCoreSelector.disabled = false;

            addToExistingTableOption.show();
            existingTableSelector.show();
        }
    }

    @:bind(createNewTableOption, UIEvent.CHANGE)
    @:bind(addToExistingTableOption, UIEvent.CHANGE)
    private function onCreateTableChanged(e:UIEvent) {
        if (createNewTableOption.selected == true) {
            newTableName.disabled = false;
            existingTableSelector.disabled = true;
        } else if (addToExistingTableOption.selected == true) {
            newTableName.disabled = true;
            existingTableSelector.disabled = false;
        }
    }

    @:bind(importFileSelector, UIEvent.CHANGE)
    private function onImportFileSelectorChanged(e:UIEvent) {
        if (createNewTableOption.selected == true && (newTableName.text == "" || newTableName.text == null)) {
            var parts = importFileSelector.text.split(".");
            parts.pop();
            newTableName.text = parts.join(".");
        }

        importFileSelector.readContents().then(function(contents) {
            _parser = new CSVDataParser();
            _parser.parse(contents);

            var fields = _parser.getFieldDefinitions();
            var ds = new ArrayDataSource<Dynamic>();
            for (f in fields) {
                ds.add({
                    fieldEnabled: true,
                    fieldName: f.fieldName,
                    fieldType: FieldType.toString(f.fieldType)
                });
            }
            importTableFields.dataSource = ds;
            importTableRowCount.text = "File contains " + _parser.getData().length + " row(s)";
            importTableRowCount.show();
        });
    }

    private var _create:Bool = false;
    @:bind(cancelButton, MouseEvent.CLICK)
    private function onCancel(e:MouseEvent) {
        _create = false;
        hide();
    }

    private var _working:WorkingIndicator;
    @:bind(createButton, MouseEvent.CLICK)
    private function onCreate(e:MouseEvent) {
        _create = true;
        hide();
    }

    private function createData() {
        if (_create == false) {
            return;
        }

        // database
        var dbName = null;
        var db = null;
        if (createNewCoreOption.selected == true) {
            dbName = newCoreName.text;
            db = new Database(dbName);
            DatabaseManager.instance.addBatchOperation(CreateDatabase, db);
        } else {
            dbName = existingCoreSelector.selectedItem.db.name;
            db = new Database(dbName);
        }

        // table
        var tableName = null;
        var table = null;
        if (createNewTableOption.selected == true) {
            tableName = newTableName.text;
            table = new Table(tableName, db);
            for (fd in _parser.getFieldDefinitions()) {
                table.defineField(fd.fieldName, FieldType.String);
            }
            DatabaseManager.instance.addBatchOperation(CreateTable, table);
        } else {
            tableName = existingTableSelector.selectedItem.table.name;
            table = new Table(tableName, db);
        }

        // data
        table.addDatas(_parser.getData());
        DatabaseManager.instance.addBatchOperation(AddTableData, table);

        _working = new WorkingIndicator();
        _working.showWorking();
        DatabaseManager.instance.performBatchOperations(function(s) {
            _working.message = s;
        }).then(function(result) {
            _working.workComplete();
            DataView.instance.refresh(dbName, tableName);
        });
    }

    private override function onHideAnimationEnd() {
        super.onHideAnimationEnd();
        createData();
    }
}