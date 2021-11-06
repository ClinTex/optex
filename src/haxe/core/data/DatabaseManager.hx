package core.data;

import core.data.CoreData.CoreResult;
import js.lib.Promise;
import core.data.CoreData.DatabaseInfo;
import core.data.CoreData.FieldType;
import core.EventDispatcher;
import core.EventDispatcher.Event;

enum DatabaseBatchOperationType {
    CreateDatabase;
    CreateTable;
    AddTableData;
}

typedef DatabaseBatchOperation = {
    var type:DatabaseBatchOperationType;
    var data:Dynamic;
}

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

    private var _batchOperations:Array<DatabaseBatchOperation> = [];
    public function addBatchOperation(type:DatabaseBatchOperationType, data:Dynamic) {
        _batchOperations.push({
            type: type,
            data: data
        });
    }

    public function performBatchOperations(onProgress:String->Void):Promise<CoreResult> {
        return new Promise((resolve, reject) -> {
            performBatches(_batchOperations.copy(), onProgress, function() {
                _batchOperations = [];
                resolve({
                    errored: false,
                    errorCode: 0,
                    errorText: ""
                });
            });
        });
    }

    private function performBatches(list:Array<DatabaseBatchOperation>, onProgress:String->Void, complete:Void->Void) {
        if (list.length == 0) {
            complete();
            return;
        }

        var item = list.shift();
        switch (item.type) {
            case CreateDatabase:
                var database:Database = cast(item.data, Database);
                if (onProgress != null) {
                    onProgress("Creating database '" + database.name + "'");
                }
                createDatabase(database.name).then(function(createdDatabase) {
                    performBatches(list, onProgress, complete);
                });
            case CreateTable:
                var table:Table = cast(item.data, Table);
                if (onProgress != null) {
                    onProgress("Creating table '" + table.name + "'");
                }
                CoreData.createTable(table.database.name, table.name, table.fieldDefinitions).then(function(createTableResult) {
                    performBatches(list, onProgress, complete);
                });
            case AddTableData:   
                var table:Table = cast(item.data, Table);
                @:privateAccess {
                    table.commitData(table._dataToAdd, onProgress).then(function(addDataResult) {
                        performBatches(list, onProgress, complete);
                    });
                }     
        }
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

    public function createDatabase(databaseName:String):Promise<Database> {
        return new Promise((resolve, reject) -> {
            Logger.instance.log("creating database '" + databaseName + "'");
            CoreData.createDatabase(databaseName).then(function(createDatabaseResult) {
                Logger.instance.log("database '" + databaseName + "' created successfully");
                getDatabase(databaseName).then(function(database) {
                    resolve(database);
                });
            });
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
