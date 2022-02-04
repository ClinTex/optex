package core.data;

import core.data.GenericData;
import core.data.dao.Database;
import core.data.dao.IDataTable;
import core.data.dao.Logger;
import core.data.internal.CoreData;
import core.data.internal.CoreData.TableInfo;
import core.data.utils.ConversionUtils;
import core.data.transforms.TransformFactory;
import core.data.transforms.TransformDetails;
import js.lib.Promise;
import core.util.FunctionDetails;

using StringTools;

class GenericTable implements IDataTable<GenericData> {
    public var db:Database;
    public var name:String;
    
    public var info:TableInfo = null;
    public var records:Array<GenericData> = [];
    
    public var primaryKeyName:String = null;

    public function new(name:String = null) {
        this.name = name;
        if (name != null) {
            info = {
                tableName: name,
                recordCount: 0,
                fieldDefinitions: []
            }
        }
    }
    
    public function createRecord(add:Bool = true) {
        var record = new GenericData();
        record.table = this;
        records.push(record);
        info.recordCount++;
        return record;
    }

    public function clone(includeData:Bool = false) {
        var copy = new GenericTable();
        copy.primaryKeyName = this.primaryKeyName;
        copy.info = {
            tableName: this.info.tableName,
            fieldDefinitions: this.info.fieldDefinitions.copy(),
            recordCount: 0
        }
        if (includeData == true) {
            copy.records = this.records.copy();
            copy.info.recordCount = this.records.length;
        }
        return copy;
    }

    public function transform(transformList:String, context:Map<String, Any>):GenericTable {
        var s = transformList;
        if (s != null && s.trim().length == 0) {
            s = null;
        }

        var transformedTable = this;

        if (s != null) {
            var transformStack:Array<TransformDetails> = [];

            var parts = s.split("->");
            for (p in parts) {
                p = p.trim();
                if (p.length == 0) {
                    continue;
                }
                var functionDetails = new FunctionDetails(p);
                transformStack.push({
                    transformId: functionDetails.name,
                    transformParameters: functionDetails.params
                });

            }
            
            for (item in transformStack) {
                var t = TransformFactory.getTransform(item.transformId);
                if (t != null) {
                    transformedTable = t.applyTransform(transformedTable, item, context);
                }
            }
        }

        return transformedTable;
    }

    public var recordCount(get, null):Int;
    private function get_recordCount():Int {
        if (this.info == null) {
            return 0;
        }
        return this.info.recordCount;
    }

    private var _dataToAdd:Array<Array<Any>> = null;
    public function addData(data:Array<Any>) {
        if (_dataToAdd == null) {
            _dataToAdd = [];
        }
        _dataToAdd.push(data);
    }

    public function addDatas(datas:Array<Array<Any>>) {
        for (d in datas) {
            addData(d);
        }
    }

    public function getFieldType(fieldIndex:Int):Int {
        var fieldDef = info.fieldDefinitions[fieldIndex];
        return fieldDef.fieldType;
    }

    public function commitData():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            if (_dataToAdd == null  || _dataToAdd.length == 0) {
                resolve(true);
                return;
            }
            var objects = [];
            for (d in _dataToAdd) {
                var object = new GenericData();
                object.fromArray(d);
                objects.push(object);
            }

            addObjects(objects, null).then(function(r) { 
                _dataToAdd = null;
                resolve(true);
            });
        });
    }

    public function defineField(fieldName:String, fieldType:Int) {
        if (info == null) {
            info = {
                tableName: this.name,
                recordCount: 0,
                fieldDefinitions: []
            }
        }
        
        var index = getFieldIndex(fieldName);
        if (index != -1) {
            throw "field " + fieldName + " already defined";
        }
        
        if (info.fieldDefinitions == null) {
            info.fieldDefinitions = [];
        }
        
        info.fieldDefinitions.push({ fieldName: fieldName, fieldType: fieldType });
    }
    
    private var _cachedFieldIndex:Map<String, Int> = [];
    public function getFieldIndex(fieldName:String):Int {
        if (info == null) {
            return -1;
        }
        if (info.fieldDefinitions == null) {
            return -1;
        }
        if (_cachedFieldIndex.exists(fieldName)) {
            return _cachedFieldIndex.get(fieldName);
        }

        var defs = info.fieldDefinitions;
        var n = 0;
        for (def in defs) {
            if (def.fieldName == fieldName) {
                _cachedFieldIndex.set(fieldName, n);
                return n;
            }
            n++;
        }
        return -1;
    }
    
    public function fetch(params:FetchParams = null):Promise<Array<GenericData>> {
        return new Promise((resolve, reject) -> {
            if (params == null) {
                params = {};
            }
            if (params.start == null) {
                params.start = 0;
            }
            if (params.end == null) {
                params.end = 0xFFFFFF;
            }

            init().then(function(r) {
                if (params.transformId == null) {
                    Logger.instance.log("" + db.name + "." + this.name + " retrieving table data");
                    CoreData.getTableData(db.name, this.name, params.start, params.end).then(function(frag) {
                        Logger.instance.log("" + db.name + "." + this.name + " data retrieved (" + frag.count + " of " + frag.total + ")");
                        var records = [];
                        for (rawRecord in frag.data) {
                            var record = new GenericData();
                            record.table = this;
                            record.fromArray(rawRecord);
                            records.push(record);
                        }
                        this.records = records;
                        resolve(records);
                    });
                } else {
                    var transformParams = [];
                    if (params.transformParameters != null) {
                        for (key in params.transformParameters.keys()) {
                            var paramsSet = [key, params.transformParameters.get(key)];
                            transformParams.push(paramsSet);
                        }
                    }
                    Logger.instance.log("" + db.name + "." + this.name + " retrieving transformed table data (transformId: " + params.transformId + ", transformParams: " + transformParams + ")");
                    CoreData.applyTableTransform(db.name, this.name, params.transformId, transformParams).then(function(frag) {
                        Logger.instance.log("" + db.name + "." + this.name + " transformed data retrieved (" + frag.data.length + " of " + frag.data.length + ")");
                        var records = [];
                        for (rawRecord in frag.data) {
                            var record = new GenericData();
                            record.table = this;
                            record.fromArray(rawRecord);
                            records.push(record);
                        }
                        this.info.fieldDefinitions = frag.fieldDefinitions;
                        this._cachedFieldIndex = [];
                        this.records = records;
                        resolve(records);
                    });
                }
            }).catchError(function(e) {
                Logger.instance.error("" + db.name + "." + this.name + " failed to retrieve data (" + e + ")");
                reject(e);
            });
        });
    }
    
    public function createObject(data:Array<Any> = null):GenericData {
        var record = new GenericData();
        record.table = this;
        if (data != null) {
            var stringArray:Array<String> = [];
            for (d in data) {
                stringArray.push(ConversionUtils.toString(d));
            }
            record.fromArray(stringArray);
        }
        return record;
    }
    
    public function updateObject(object:GenericData):Promise<Bool> {
        return new Promise((resolve, reject) -> {
            init().then(function(r) {
                resolve(true);
            });
        });
    }
    
    public function addObject(object:GenericData):Promise<Bool> {
        return new Promise((resolve, reject) -> {
            init().then(function(r) {
                resolve(true);
            });
        });
    }
    
    public var batchSize:Int = 5000;
    public function addObjects(objects:Array<GenericData>, onProgress:Int->Int->Void = null):Promise<Bool> {
        return new Promise((resolve, reject) -> {
            var batches:Array<Array<Array<String>>> = [];
            var n = 0;
            var batch = [];
            for (o in objects) {
                var objectData = o.toArray().copy();
                batch.push(objectData);
                n++;
                
                if (n >= batchSize) {
                    n = 0;
                    batches.push(batch);
                    batch = [];
                }
            }
            
            if (batch.length > 0) {
                batches.push(batch);
            }
            
            Logger.instance.log("" + db.name + "." + this.name + " adding " + objects.length + " objects in " + batches.length + " batches of " + batchSize); 
            processBatches(batches, function() {
                resolve(true);
            }, onProgress, 0, batches.length);
        });
    }
    
    private function processBatches(batches:Array<Array<Array<String>>>, onComplete:Void->Void, onProgress:Int->Int->Void, current:Int, max:Int) {
        if (batches.length == 0) {
            onComplete();
            return;
        }
        
        if (onProgress != null) {
            onProgress(current + 1, max);
        }
        
        var batch = batches.shift();
        Logger.instance.log("" + db.name + "." + this.name + " processing batch " + (current + 1) + " of " + max + " (" + batch.length + " items)"); 
        CoreData.addTableData(db.name, this.name, batch).then(function(batchResult) {
            processBatches(batches, onComplete, onProgress, current + 1, max);
        });
    }
    
    public function init():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            if (info != null) {
                Logger.instance.log("" + db.name + "." + this.name + " already initialized, returning");
                resolve(true);
                return;
            }
            
            Logger.instance.log(db.name + "." + this.name + " initializing");
            CoreData.hasTable(db.name, this.name).then(function(hasTable) {
                if (hasTable == false) {
                    create().then(function(createResult) {
                        resolve(true);
                    }).catchError(function(e) {
                        Logger.instance.error("" + db.name + "." + this.name + " failed to create table during initialization (" + e + ")");
                        reject(e);
                    });
                } else {
                    Logger.instance.log("" + db.name + "." + this.name + " exists, continuing");
                    CoreData.getTableInfo(db.name, this.name).then(function(tableInfo) {
                        resolve(true);
                        this.info = tableInfo;
                    }).catchError(function(e) {
                        Logger.instance.error("" + db.name + "." + this.name + " failed to retrieve table info (" + e + ")");
                        reject(e);
                    });
                }
                resolve(true);
            }).catchError(function(e) {
                Logger.instance.error("" + db.name + "." + this.name + " failed to initialize (" + e + ")");
                reject(e);
            });
        });
    }
    
    public function remove():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            Logger.instance.log("" + db.name + "." + this.name + " removing table");
            CoreData.removeTable(db.name, this.name).then(function(r) {
                resolve(true);
            });
        });
    }

    public function create():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            Logger.instance.log("" + db.name + "." + this.name + " creating table");
            if (db == null) {
                reject("no assocated database");
                return;
            }
            if (info == null) {
                reject("no table info");
                return;
            }
            if (info.tableName == null || info.tableName.length == 0) {
                reject("no table name");
                return;
            }
            var fieldDefs = info.fieldDefinitions;
            if (fieldDefs == null || fieldDefs.length == 0) {
                reject("no field definitions");
                return;
            }

            CoreData.createTable(db.name, this.name, fieldDefs).then(function(createTableResult) {
                Logger.instance.log("" + db.name + "." + this.name + " table created");
                addDefaultData().then(function(r) {
                    CoreData.getTableInfo(db.name, this.name).then(function(tableInfo) {
                        this.info = tableInfo;
                        resolve(true);
                    }).catchError(function(e) {
                        Logger.instance.error("" + db.name + "." + this.name + " failed to retrieve table info (" + e + ")");
                        reject(e);
                    });
                });
            }).catchError(function(e) {
                Logger.instance.error("" + db.name + "." + this.name + " failed to create table (" + e + ")");
                reject(e);
            });
        });
    }

    public function addDefaultData():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            resolve(true);
        });
    }
}