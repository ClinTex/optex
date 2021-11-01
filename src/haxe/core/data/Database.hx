package core.data;

import core.data.CoreData.DatabaseInfo;
import core.data.CoreData.CoreResult;
import js.lib.Promise;

class Database {
    public var name:String;

    private var _create:Bool = false;
    private var _tablesToCreate:Array<Table> = [];
    private var _tablesToCommit:Array<Table> = [];
    private var _info:DatabaseInfo;

    public function new(name:String, info:DatabaseInfo = null) {
        this.name = name;
        _info = info;
    }

    public var onProgress:String->Void = null;
    private function progress(message:String) {
        if (onProgress != null) {
            onProgress(message);
        }
    }

    public function create() {
        _create = true;
        return this;
    }

    public function createTable(name:String) {
        var table = new Table(name, this);
        table.onProgress = this.onProgress;
        table.create();
        _tablesToCreate.push(table);
        return table;
    }

    public function listTables(live:Bool = true):Promise<Array<Table>>  {
        return new Promise((resolve, reject) -> {
            if (live == false && _info != null) {
                var tables = [];
                for (t in _info.tables) {
                    var table = new Table(t.tableName, this, t);
                    table.onProgress = this.onProgress;
                    tables.push(table);
                }
                resolve(tables);
                return;
            }

            CoreData.getDatabaseInfo(name).then(function(info) {
                var tables = [];
                for (t in info.tables) {
                    var table = new Table(t.tableName, this, t);
                    table.onProgress = this.onProgress;
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

    public function getTable(name:String, live:Bool = true):Table {
        var table = new Table(name, this);
        table.onProgress = this.onProgress;

        var exists:Bool = false;
        for (t in _tablesToCommit) {
            if (t.name == table.name) {
                exists = true;
                break;
            }
        }

        if (exists == false) {
            _tablesToCommit.push(table);
        }

        return table;
    }

    public function commit():Promise<CoreResult>  {
        return new Promise((resolve, reject) -> {
            if (_create == true) {
                Logger.instance.log("creating database '" + name + "'");
                progress("Creating database '" + name + "'");
                CoreData.createDatabase(name).then(function(createResult:CoreResult) {
                    if (createResult.errored == true) {
                        Logger.instance.log("problem creating database '" + name + "': " + createResult.errorText + " (" + createResult.errorCode + ")");
                        resolve(createResult);
                    } else {
                        Logger.instance.log("database '" + name + "' created successfully");
                        if (_tablesToCreate.length > 0) {
                            Logger.instance.log("creating " + _tablesToCreate.length + " table(s) in database '" + name + "'");
                            commitTables(_tablesToCreate.copy(), function() {
                                Logger.instance.log("table(s) created in database '" + name + "'");
                                resolve({
                                    errored: false,
                                    errorCode: 0,
                                    errorText: ""
                                });
                            });
                        }
                    }
                });
            } else {
                if (_tablesToCommit.length > 0) {
                    Logger.instance.log("committing " + _tablesToCommit.length + " table(s) in database '" + name + "'");
                    commitTables(_tablesToCommit.copy(), function() {
                        Logger.instance.log("table(s) committed in database '" + name + "'");
                        resolve({
                            errored: false,
                            errorCode: 0,
                            errorText: ""
                        });
                    });
                } else if (_tablesToCreate.length > 0) {
                    Logger.instance.log("creating " + _tablesToCreate.length + " table(s) in database '" + name + "'");
                    commitTables(_tablesToCreate.copy(), function() {
                        Logger.instance.log("table(s) created in database '" + name + "'");
                        resolve({
                            errored: false,
                            errorCode: 0,
                            errorText: ""
                        });
                    });
                }
            }
        });
    }

    private function commitTables(list:Array<Table>, complete:Void->Void) {
        if (list.length == 0) {
            complete();
            return;
        }

        var table = list.shift();
        table.commit().then(function(commitResult:CoreResult) {
            commitTables(list, complete);
        });
    }
}
