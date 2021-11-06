package core.data;

import core.data.CoreData.DatabaseInfo;
import core.data.CoreData.CoreResult;
import core.data.CoreData.TableFieldInfo;
import js.lib.Promise;

class Database {
    public var name:String;

    private var _info:DatabaseInfo;

    public function new(name:String, info:DatabaseInfo = null) {
        this.name = name;
        _info = info;
    }

    public function createTable(tableName:String, fieldDefinitions:Array<TableFieldInfo>):Promise<Table> {
        return new Promise((resolve, reject) -> {
            CoreData.createTable(this.name, tableName, fieldDefinitions).then(function(createTableResult) {
                getTable(tableName).then(function(table) {
                    resolve(table);
                });
            });
        });
    }

    public function getTable(tableName:String):Promise<Table> {
        return new Promise((resolve, reject) -> {
            CoreData.getTableInfo(name, tableName).then(function(tableInfo) {
                var table = new Table(tableName, this, tableInfo);
                resolve(table);
            });
        });
    }

    public function listTables():Promise<Array<Table>>  {
        return new Promise((resolve, reject) -> {
            CoreData.getDatabaseInfo(name).then(function(info) {
                var tables = [];
                for (t in info.tables) {
                    var table = new Table(t.tableName, this, t);
                    tables.push(table);
                }
                resolve(tables);
            });
        });
    }

    public function removeTable(tableName:String):Promise<CoreResult> {
        return new Promise((resolve, reject) -> {
            CoreData.removeTable(name, tableName).then(function(r) {
                resolve(r);
            });
        });
    }
}
