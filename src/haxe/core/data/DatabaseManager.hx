package core.data;

import core.data.CoreData.CoreResult;
import js.lib.Promise;
import core.data.CoreData.DatabaseInfo;
import core.data.CoreData.FieldType;
import core.EventDispatcher;
import core.EventDispatcher.Event;

class DatabaseEvent extends Event {
    public static inline var Initialized = "initialized";
}

class DatabaseManager extends EventDispatcher<DatabaseEvent> {
    private static var _instance:DatabaseManager = null;
    public static var instance(get, null):DatabaseManager;
    private static function get_instance():DatabaseManager {
        if (_instance == null) {
            _instance = new DatabaseManager();
        }
        return _instance;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // INSTANCE
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    public var internalData:Database = null;
    public var dashboardsData:Table = null;

    private function new() {
    }

    public function init():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            var tables = [];
            var table = new Table("dashboards");
                table.defineField("dashboardName", FieldType.String);
                table.defineField("dashboardLayoutData", FieldType.String);
            tables.push(table);

            createDatabaseIfDoesntExist("__optex_internal_data", tables).then(function(r) {
                getDatabase("__optex_internal_data").then(function(db) {
                    internalData = db;
                    internalData.getTable("dashboards").then(function(t) {
                        dashboardsData = t;
                        resolve(true);
                        dispatch(new DatabaseEvent(DatabaseEvent.Initialized));
                    });
                });
            });

        });
    }

    public function createDatabaseIfDoesntExist(databaseName:String, tablesToCreate:Array<Table>):Promise<Bool> {
        return new Promise((resolve, reject) -> {
            CoreData.hasDatabase(databaseName).then(function(hasDatabase) {
                if (hasDatabase == false) {
                    CoreData.createDatabase(databaseName).then(function(createDatabaseResult) {
                        createTablesIfDontExist(databaseName, tablesToCreate.copy(), function() {
                            resolve(true);
                        });
                    });
                } else {
                    createTablesIfDontExist(databaseName, tablesToCreate.copy(), function() {
                        resolve(true);
                    });
                }
            });
        });
    }

    private function createTablesIfDontExist(databaseName:String, tablesToCreate:Array<Table>, complete:Void->Void) {
        if (tablesToCreate.length == 0) {
            complete();
            return;
        }

        var table = tablesToCreate.shift();
        CoreData.hasTable(databaseName, table.name).then(function(hasTable) {
            if (hasTable) {
                createTablesIfDontExist(databaseName, tablesToCreate, complete);
            } else {
                CoreData.createTable(databaseName, table.name, table.fieldDefinitions).then(function(createTableResult) {
                    createTablesIfDontExist(databaseName, tablesToCreate, complete);
                });
            }
        });
    }

    public function getDatabase(databaseName:String):Promise<Database> {
        return new Promise((resolve, reject) -> {
            CoreData.getDatabaseInfo(databaseName).then(function(info) {
                var db = new Database(databaseName, info);
                resolve(db);
            });
        });
    }

    public function listDatabases():Promise<Array<Database>> {
        return new Promise((resolve, reject) -> {
            CoreData.listDatabases().then(function(dbs:Array<DatabaseInfo>) {
                var list = [];
                for (db in dbs) {
                    list.push(new Database(db.databaseName, db));
                }
                resolve(list);
            });
        });
    }

    public function removeDatabase(databaseName):Promise<CoreResult> {
        return new Promise((resolve, reject) -> {
            CoreData.removeDatabase(databaseName).then(function(result) {
                resolve(result);
            });
        });
    }
}
