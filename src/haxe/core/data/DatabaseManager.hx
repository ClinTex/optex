package core.data;

import core.EventDispatcher.Event;
import js.lib.Reflect;
import core.data.GenericTable;
import core.data.utils.PromiseUtils;
import core.data.dao.Database;
import core.data.internal.CoreData;
import js.lib.Promise;

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
    public static inline var Initialized = "dbInitialized";
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

    //////////////////////////////////////////////////////////////////////////////////////////

    public var internal:InternalDB = null;
    private var _cachedDatabases:Array<Database> = null;

    public function new() {
        internal = InternalDB.instance;
    }

    public function init():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            var promises = [internal.init()];

            PromiseUtils.runSequentially(promises, function() {
                resolve(true);
                dispatch(new DatabaseEvent(DatabaseEvent.Initialized));
            });
        });
    }

    public function getDatabase(name:String):Promise<Database> {
        return new Promise((resolve, reject) -> {
            CoreData.getDatabaseInfo(name).then(function(databaseDef) {
                var db = new Database();
                db.name = databaseDef.databaseName;
                db.info = databaseDef;

                for (tableDef in databaseDef.tables) {
                    var table = new GenericTable();
                    table.info = tableDef;
                    db.registerTable(tableDef.tableName, table);
                }

                resolve(db);
            });
        });
    }

    public function listDatabases(useCache:Bool = true):Promise<Array<Database>> {
        return new Promise((resolve, reject) -> {
            if (useCache == true && _cachedDatabases != null) {
                resolve(_cachedDatabases);
                return;
            }

            CoreData.listDatabases().then(function(databaseDefs) {
                var dbs = [];
                for (databaseDef in databaseDefs) {
                    var db = new Database();
                    db.name = databaseDef.databaseName;
                    db.info = databaseDef;
                    dbs.push(db);
                    
                    for (tableDef in databaseDef.tables) {
                        var table = new GenericTable();
                        table.info = tableDef;
                        db.registerTable(tableDef.tableName, table);
                    }
                }

                _cachedDatabases = dbs;
                resolve(dbs);
            });
        });
    }

    private var _batchOperations:Array<DatabaseBatchOperation> = null;
    public function addBatchOperation(type:DatabaseBatchOperationType, data:Dynamic) {
        if (_batchOperations == null) {
            _batchOperations = [];
        }
        _batchOperations.push({
            type: type,
            data: data
        });
    }

    public function performBatchOperations(onProgress:DatabaseBatchOperation->Int->Int->Void):Promise<Bool> {
        return new Promise((resolve, reject) -> {
            performBatches(_batchOperations.copy(), 0, _batchOperations.length, function() {
                resolve(true);
            }, onProgress);
        });
    }

    private function performBatches(list:Array<DatabaseBatchOperation>, current:Int, max:Int, onComplete:Void->Void, onProgress:DatabaseBatchOperation->Int->Int->Void) {
        if (list.length == 0) {
            onComplete();
            return;
        }

        var item = list.shift();
        if (onProgress != null) {
            onProgress(item, (current + 1), max);
        }

        switch (item.type) {
            case CreateDatabase:
                var db = cast(item.data, Database);
                db.create().then(function(r) {
                    performBatches(list, current + 1, max, onComplete, onProgress);
                });
            case CreateTable:
                var table = cast(item.data, GenericTable);
                table.create().then(function(r) {
                    performBatches(list, current + 1, max, onComplete, onProgress);
                });
            case AddTableData:
                var table = cast(item.data, GenericTable);
                table.commitData().then(function(r) {
                    performBatches(list, current + 1, max, onComplete, onProgress);
                });
        }
    }
}