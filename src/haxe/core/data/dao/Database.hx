package core.data.dao;

import js.lib.Promise;
import core.data.GenericTable;
import core.data.internal.CoreData;
import core.data.internal.CoreData.DatabaseInfo;

class Database {
    public var name:String = null;
    public var info:DatabaseInfo = null;

    private var _tables:Map<String, Dynamic> = [];
    
    public function new() {
    }
    
    public function listTables():Promise<Array<GenericTable>> {
        return new Promise((resolve, reject) -> {
            Logger.instance.log(this.name + " - retrieving database tables");
            CoreData.getDatabaseInfo(name).then(function(databaseDef) {
                info = databaseDef;
                _tables = [];
                var tables = [];
                for (tableDef in info.tables) {
                    var table:GenericTable = new GenericTable();
                    table.db = this;
                    table.name = tableDef.tableName;
                    table.info = tableDef;
                    _tables.set(table.name, table);
                    tables.push(table);
                }

                resolve(tables);
            });
        });
    }

    public function create():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            CoreData.hasDatabase(this.name).then(function(exists) {
                if (exists == true) {
                    Logger.instance.log(this.name + " already exists, skipping");
                    resolve(true);
                } else {
                    Logger.instance.log(this.name + " - creating database");
                    CoreData.createDatabase(this.name).then(function(result) {
                        CoreData.getDatabaseInfo(this.name).then(function(info) {
                            this.info = info;
                            resolve(true);
                        });
                    });
                }
            });
        });
    }

    public function remove():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            Logger.instance.log(this.name + " - removing database");
            CoreData.removeDatabase(this.name).then(function(result) {
                resolve(true);
            });
        });
    }

    public var tables(get, null):Array<GenericTable>;
    private function get_tables():Array<GenericTable> {
        var t = [];
        for (key in _tables.keys()) {
            var table:GenericTable = _tables.get(key);
            t.push(table);
        }
        return t;
    }
    
    public function registerTable<T>(tableName:String, table:IDataTable<T>) {
        table.db = this;
        table.name = tableName;
        _tables.set(tableName, table);
    }
    
    public function getTable<T>(tableName:String):IDataTable<T> {
        return _tables.get(tableName);        
    }
}