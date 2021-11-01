package core.data;

import core.data.CoreData.CoreResult;
import js.lib.Promise;
import core.data.CoreData.DatabaseInfo;

class DatabaseManager {
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
    private function new() {
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
