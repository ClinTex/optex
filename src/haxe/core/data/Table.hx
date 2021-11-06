package core.data;

import core.data.CoreData.TableFragment;
import core.data.CoreData.TableInfo;
import js.lib.Promise;
import core.data.CoreData.CoreResult;
import core.data.CoreData.TableFieldInfo;

class Table {
    public var name:String; 

    private var _info:TableInfo;

    public var database:Database;
    private var _fieldDefs:Array<TableFieldInfo> = [];
    private var _dataToAdd:Array<Array<Any>> = [];

    public function new(name:String, database:Database = null, info:TableInfo = null) {
        this.name = name;
        this.database = database;
        _info = info;
        if (_info != null) {
            _fieldDefs = _info.fieldDefinitions;
        }
    }

    public var fieldDefinitions(get, set):Array<TableFieldInfo>;
    private function get_fieldDefinitions():Array<TableFieldInfo> {
        return _fieldDefs;
    }
    private function set_fieldDefinitions(value:Array<TableFieldInfo>):Array<TableFieldInfo> {
        _fieldDefs = value;
        return value;
    }

    public function defineField(fieldName:String, fieldType:Int) {
        _fieldDefs.push({
            fieldName: fieldName,
            fieldType: fieldType
        });
    }

    public function addData(values:Array<Any>) {
        _dataToAdd.push(values);
        return this;
    }

    public function addDatas(values:Array<Array<Any>>) {
        for (v in values) {
            addData(v);
        }
    }

    public function getRowCount():Int {
        if (_info != null) {
            return _info.recordCount;
        }
        return 0;
    }

    public function getRows(start:Int, end:Int):Promise<TableFragment> {
        return new Promise((resolve, reject) -> {
            CoreData.getTableData(database.name, name, start, end).then(function(f) {
                resolve(f);
            });
        });
    }

    public function updateData(fieldName:String, fieldValue:String, newData:Array<String>):Promise<CoreResult> {
        return new Promise((resolve, reject) -> {
            CoreData.updateTableData(database.name, name, fieldName, fieldValue, newData).then(function(result) {
                resolve(result);
            });
        });
    }

    public function commit():Promise<CoreResult> {
        return new Promise((resolve, reject) -> {
            if (_dataToAdd != null && _dataToAdd.length > 0) {
                commitData(_dataToAdd, null).then(function(dataCreateResult) {
                    resolve(dataCreateResult);
                });
            } else {
                resolve({
                    errored: false,
                    errorCode: 0,
                    errorText: ""
                });
            }
        });
    }

    public var addDataBatchSize:Int = 5000;
    private function commitData(data:Array<Array<Any>>, onProgress:String->Void):Promise<CoreResult> {
        return new Promise((resolve, reject) -> {
            var batches:Array<Array<Array<String>>> = [];
            var n = 0;
            var fixedData = [];
            for (r in data) {
                var fixedRow = [];
                for (v in r) {
                    fixedRow.push(Std.string(v));
                }
                fixedData.push(fixedRow);
                n++;
                if (n >= addDataBatchSize) {
                    n = 0;
                    batches.push(fixedData);
                    fixedData = [];
                }
            }
            if (fixedData.length > 0) {
                batches.push(fixedData);
            }
    
            Logger.instance.log("creating " + data.length + " row(s) in '" + database.name + "." + name + "' using " + batches.length + " batch(es)");
            batchCommitData(batches, function() {
                Logger.instance.log("creation of " + data.length + " row(s) in '" + database.name + "." + name + "' complete");
                resolve({
                    errored: false,
                    errorCode: 0,
                    errorText: ""
                });
            }, onProgress, 0, batches.length);
        });
    }

    private function batchCommitData(batches:Array<Array<Array<String>>>, complete:Void->Void, onProgress:String->Void, current:Int, max:Int) {
        if (batches.length == 0) {
            complete();
            return;
        }

        if (onProgress != null) {
            if (max > 1) {
                onProgress("Adding data (batch " + (current + 1) + " of " + max + ")");
            } else {
                onProgress("Adding data");
            }
        }

        var batch = batches.shift();
        Logger.instance.log("batching commiting " + batch.length + " row(s) to '" + database.name + "." + name + "'");
        CoreData.addTableData(database.name, name, batch).then(function(addDataResult) {
            Logger.instance.log("batch commit of " + batch.length + " row(s) to '" + database.name + "." + name + "' complete");
            batchCommitData(batches, complete, onProgress, current + 1, max);
        });
    }
}
