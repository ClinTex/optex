package core.components.portlets;

import core.data.DataSourceData;
import core.data.InternalDB;
import core.data.GenericTable;
import core.components.portlets.PortletInstance;
import js.lib.Promise;
import core.data.DatabaseManager;
import core.data.dao.Database;

class PortletDataUtils {
    private static var _databaseCache:Map<String, Database> = [];
    public static function getDatabase(databaseName:String):Promise<Database> {
        return new Promise((resolve, reject) -> {
            if (_databaseCache.exists(databaseName)) {
                resolve(_databaseCache.get(databaseName));
                return;
            }

            DatabaseManager.instance.getDatabase(databaseName).then(function(db) {
                _databaseCache.set(databaseName, db);
                resolve(db);
            });
        });
    }

    private static var _tableCache:Map<String, GenericTable> = [];
    public static function fetchTableData(databaseName:String, tableName:String):Promise<GenericTable> {
        return new Promise((resolve, reject) -> {
            var key = databaseName + "." + tableName;
            if (_tableCache.exists(key)) {
                var table = _tableCache.get(key);
                var copy = table.clone(true);
                resolve(copy);
                return;
            }
            getDatabase(databaseName).then(function(db) {
                var table:GenericTable = cast db.getTable(tableName);
                table.fetch().then(function(_) {
                    var copy = table.clone(true);
                    _tableCache.set(key, copy);
                    resolve(copy);
                });
            });
        });
    }
}