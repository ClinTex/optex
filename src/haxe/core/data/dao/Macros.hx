package core.data.dao;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.Field;
import haxe.macro.TypeTools;
import haxe.macro.ExprTools;
import haxe.ui.macros.helpers.ClassBuilder;
import haxe.ui.macros.helpers.CodeBuilder;

using StringTools;

class Macros {
    macro public static function buildDataObject():Array<Field> {
        var builder = new ClassBuilder(Context.getBuildFields(), Context.getLocalType(), Context.currentPos());

        var complexType:ComplexType = TypeTools.toComplexType(Context.getLocalType());
        
        var tableName = builder.name.toLowerCase();
        builder.addVar("TableName", macro: String, macro $v{tableName}, [APublic, AStatic]);
        builder.addVar("table", macro: core.data.dao.IDataTable<$complexType>);
        builder.addVar("links", macro: Map<String, core.data.dao.IDataObject>, macro []);
        builder.addVar("dataChanged", macro: Bool, macro false, [APrivate]);
        
        var ctor = builder.ctor;
        if (ctor == null) {
            ctor = builder.addFunction("new");
        }
        
        var fromArrayFn = builder.addFunction("fromArray", null, [{name: "data", type: macro: Array<String>}]);
        var toArrayFn = builder.addFunction("toArray", null, null, macro: Array<String>);
        var setLinkObjectFn = builder.addFunction("setLinkObject", null, [{name: "fieldId", type: macro: String}, {name: "object", type: macro: Any}]);
        var getFieldValueFn = builder.addFunction("getFieldValue", null, [{name: "fieldId", type: macro: String}], macro: Any);
        
        toArrayFn.add(macro var data = []);

        var primaryKeyGetterExpr = new CodeBuilder();
        var primaryKeySetterExpr = new CodeBuilder();
        var primaryKeyNameExpr = new CodeBuilder();
        var primaryFieldDefsExpr:Array<Expr> = [];
        var fieldDefsExpr:Array<Expr> = [];
        var linkedFieldsExpr:Array<Expr> = [];
        
        var n = 0;
        for (f in builder.getFieldsWithMeta("field")) {
            f.remove();
            var fieldVarName = "_" + f.name;
            builder.addVar(fieldVarName, f.type, f.expr, [APrivate], f.meta);
            builder.addGetter(f.name, f.type, macro {
                return $i{fieldVarName};
            });
            builder.addSetter(f.name, f.type, macro {
                if ($i{fieldVarName} == value) {
                    return value;
                }
                dataChanged = true;
                $i{fieldVarName} = value;
                return value;
            });
            
            var e = toFieldType(f.type);
            fromArrayFn.add(macro $i{f.name} = core.data.utils.ConversionUtils.fromString(data[$v{n}], ${e}));
            toArrayFn.add(macro data.push(core.data.utils.ConversionUtils.toString($i{f.name})));
            getFieldValueFn.add(macro if (fieldId == $v{f.name}) return $i{f.name});
            
            fieldDefsExpr.push(macro {fieldName: $v{f.name}, fieldType: ${e}});

            if (f.getMetaValueString("field") == "primary") {
                primaryFieldDefsExpr.push(macro {fieldName: $v{f.name}, fieldType: ${e}});
                primaryKeyGetterExpr.add(macro return $i{f.name});
                primaryKeySetterExpr.add(macro return $i{f.name} = value);
                primaryKeyNameExpr.add(macro return $v{f.name});
            }
            
            n++;
        }
        for (f in builder.getFieldsWithMeta("link")) {
            f.remove();
            var fieldVarName = "_" + f.name;
            builder.addVar(fieldVarName, f.type, f.expr, [APrivate], f.meta);
            builder.addGetter(f.name, f.type, macro {
                return $i{fieldVarName};
            });
            builder.addSetter(f.name, f.type, macro {
                if ($i{fieldVarName} == value) {
                    return value;
                }
                setLinkObject(value.primaryKeyName, value);
                $i{fieldVarName} = value;
                return value;
            });

            var linkField = f.getMetaValueString("link");
            var linkTypePath = f.typePath;
            var linkTableName = linkTypePath.name.toLowerCase();
            getFieldValueFn.add(macro if (fieldId == $v{f.name}) return $i{f.name});
            linkedFieldsExpr.push(macro {tableName: $v{linkTableName}, fieldName: $v{linkField}});
            setLinkObjectFn.add(macro if (fieldId == $v{linkField}) {
                $i{fieldVarName} = object;
                links.set($v{f.name}, $i{fieldVarName});
            });
        }
        
        builder.addVar("FieldDefinitions", macro: Array<core.data.internal.CoreData.TableFieldInfo>, macro $a{fieldDefsExpr}, [APublic, AStatic]);
        builder.addVar("PrimaryFieldDefinitions", macro: Array<core.data.internal.CoreData.TableFieldInfo>, macro $a{primaryFieldDefsExpr}, [APublic, AStatic]);
        builder.addVar("LinkedFields", macro: Array<core.data.dao.LinkedFieldInfo>, macro $a{linkedFieldsExpr}, [APublic, AStatic]);
        
        toArrayFn.add(macro return data);
        fromArrayFn.add(macro dataChanged = false);
        getFieldValueFn.add(macro return null);
        var primaryKeyGetter = builder.addGetter("primaryKey", macro: Int, primaryKeyGetterExpr.expr);
        var primaryKeySetter = builder.addSetter("primaryKey", macro: Int, primaryKeySetterExpr.expr);
        var primaryKeyNameGetter = builder.addGetter("primaryKeyName", macro: String, primaryKeyNameExpr.expr);

        //////////////////////////////////////////////////////////////////////////////////////////////
        
        var addFn = builder.addFunction("add", null, null, macro: js.lib.Promise<Bool>);
        addFn.add(macro {
            return new js.lib.Promise((resolve, reject) -> {
                var list = [];

                for (k in links.keys()) {
                    var link = links.get(k);
                    if (link != null) {
                        list.push(link.add());
                    }
                }

                list.push(table.addObject(this));
                
                core.data.utils.PromiseUtils.runSequentially(list, function() {
                    dataChanged = false;
                    resolve(true);
                }, function(e) {
                    reject(e);
                });
            });
        });

        //////////////////////////////////////////////////////////////////////////////////////////////
        
        var deleteFn = builder.addFunction("delete", null, null, macro: js.lib.Promise<Bool>);
        deleteFn.add(macro {
            return new js.lib.Promise((resolve, reject) -> {
                resolve(true);
            });
        });

        //////////////////////////////////////////////////////////////////////////////////////////////
        
        var updateFn = builder.addFunction("update", null, null, macro: js.lib.Promise<Bool>);
        updateFn.add(macro {
            return new js.lib.Promise((resolve, reject) -> {
                var list = [];
                if (dataChanged == true) {
                    list.push(table.updateObject(this));
                }
                for (k in links.keys()) {
                    var link = links.get(k);
                    if (link != null) {
                        list.push(link.update());
                    }
                }
                if (list.length != 0) {
                    core.data.utils.PromiseUtils.runSequentially(list, function() {
                        dataChanged = false;
                        resolve(true);
                    }, function(e) {
                        reject(e);
                    });
                } else {
                    resolve(true);
                }
            });
        });
        return builder.fields;
    }
    
    macro public static function buildDataTable(recordClass:Expr):Array<Field> {
        var builder = new ClassBuilder(Context.getBuildFields(), Context.getLocalType(), Context.currentPos());

        var typeName = ExprTools.toString(recordClass);
        var typePath:TypePath = {pack: ["core", "data"], name: typeName };
        var complexType:ComplexType = TPath(typePath);
        
        var ctor = builder.ctor;
        if (ctor == null) {
            ctor = builder.addFunction("new");
        }
        
        //////////////////////////////////////////////////////////////////////////////////////////////
        
        var tableName = typePath.name.toLowerCase();
        builder.addVar("TableName", macro: String, macro $v{tableName}, [APublic, AStatic]);
        
        builder.addVar("info", macro: core.data.internal.CoreData.TableInfo);
        builder.addVar("db", macro: core.data.dao.Database);
        builder.addVar("name", macro: String);
        
        //////////////////////////////////////////////////////////////////////////////////////////////
        
        var fetchFn = builder.addFunction("fetch", null, [{name: "params", type: macro: core.data.dao.IDataTable.FetchParams, value: macro null}], macro: js.lib.Promise<Array<$complexType>>);
        fetchFn.add(macro {
            return new js.lib.Promise((resolve, reject) -> {
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
                    core.data.dao.Logger.instance.log("" + db.name + "." + $v{tableName} + " retrieving table data");
                    core.data.internal.CoreData.getTableData(db.name, $v{tableName}, params.start, params.end).then(function(frag) {
                        core.data.dao.Logger.instance.log("" + db.name + "." + $v{tableName} + " data retrieved (" + frag.count + " of " + frag.total + ")");
                        var records = [];
                        var linkInfoMap:Map<String, Array<String>> = [];
                        var hasLinks:Bool = false;
                        for (rawRecord in frag.data) {
                            var record = new $typePath();
                            record.table = this;
                            record.fromArray(rawRecord);
                            records.push(record);
                            
                            for (linkField in $i{typeName}.LinkedFields) {
                                hasLinks = true;
                                var list = linkInfoMap.get(linkField.tableName + "$" + linkField.fieldName);
                                if (list == null) {
                                    list = [];
                                    linkInfoMap.set(linkField.tableName + "$" + linkField.fieldName, list);
                                }
                                var value = core.data.utils.ConversionUtils.toString(record.getFieldValue(linkField.fieldName));
                                if (list.indexOf(value) == -1) {
                                    list.push(value);
                                }
                            }
                        }
                        
                        if (hasLinks == true) {
                            var linkPromises = [];
                            for (linkKey in linkInfoMap.keys()) {
                                var parts = linkKey.split("$");
                                var tableName = parts[0];
                                var fieldName = parts[1];
                                var fieldValues = linkInfoMap.get(linkKey);
                                core.data.dao.Logger.instance.log("" + db.name + "." + $v{tableName} + " looking up links based on " + fieldName + ": " + fieldValues);
                                linkPromises.push(buildLinks(tableName, fieldName, records));
                            }
                            
                            js.lib.Promise.all(linkPromises).then(function(_) {
                                resolve(records);
                            }).catchError(function(e) {
                                core.data.dao.Logger.instance.error("" + db.name + "." + $v{tableName} + " failed to retrieve data (" + e + ")");
                                reject(e);
                            });
                        } else {
                            resolve(records);
                        }
                    }).catchError(function(e) {
                        core.data.dao.Logger.instance.error("" + db.name + "." + $v{tableName} + " failed to retrieve data (" + e + ")");
                        reject(e);
                    });
                }).catchError(function(e) {
                    core.data.dao.Logger.instance.error("" + db.name + "." + $v{tableName} + " failed to retrieve data (" + e + ")");
                    reject(e);
                });
            });
        });

        //////////////////////////////////////////////////////////////////////////////////////////////
        
        var updateObjectFn = builder.addFunction("updateObject", null, [{name: "object", type: macro: $complexType}], macro: js.lib.Promise<Bool>);
        updateObjectFn.add(macro {
            return new js.lib.Promise((resolve, reject) -> {
                init().then(function(r) {
                    core.data.dao.Logger.instance.log(db.name + "." + $v{tableName} + " updating object - " + object.toArray());
                    var primaryKeyName = $i{typeName}.PrimaryFieldDefinitions[0].fieldName;
                    core.data.internal.CoreData.updateTableData(db.name, $v{tableName}, primaryKeyName, core.data.utils.ConversionUtils.toString(object.primaryKey), object.toArray()).then(function(r) {
                        resolve(true);
                    }).catchError(function(e) {
                        core.data.dao.Logger.instance.error("" + db.name + "." + $v{tableName} + " failed to update object (" + e + ")");
                        reject(e);
                    });
                }).catchError(function(e) {
                    core.data.dao.Logger.instance.error("" + db.name + "." + $v{tableName} + " failed to update object (" + e + ")");
                    reject(e);
                });
            });
        });
        
        //////////////////////////////////////////////////////////////////////////////////////////////

        var addObjectFn = builder.addFunction("addObject", null, [{name: "object", type: macro: $complexType}], macro: js.lib.Promise<Bool>);
        addObjectFn.add(macro {
            return new js.lib.Promise((resolve, reject) -> {
                init().then(function(r) {
                    core.data.dao.Logger.instance.log(db.name + "." + $v{tableName} + " adding object - " + object.toArray());
                    var data = object.toArray();
                    core.data.internal.CoreData.addTableData(db.name, $v{tableName}, [data]).then(function(r) {
                        resolve(true);
                    }).catchError(function(e) {
                        core.data.dao.Logger.instance.error("" + db.name + "." + $v{tableName} + " failed to add object (" + e + ")");
                        reject(e);
                    });
                }).catchError(function(e) {
                    core.data.dao.Logger.instance.error("" + db.name + "." + $v{tableName} + " failed to add object (" + e + ")");
                    reject(e);
                });
            });
        });
        
        //////////////////////////////////////////////////////////////////////////////////////////////
        
        var createObjectFn = builder.addFunction("createObject", null, [{name: "data", type: macro: Array<Any>, value: macro null}], macro: $complexType);
        createObjectFn.add(macro {
            var record = new $typePath();
            record.table = this;
            if (data != null) {
                var stringArray:Array<String> = [];
                for (d in data) {
                    stringArray.push(core.data.utils.ConversionUtils.toString(d));
                }
                record.fromArray(stringArray);
            }
            return record;
        });
        //////////////////////////////////////////////////////////////////////////////////////////////
        
        var buildLinksFn = builder.addFunction("buildLinks", null, [{name: "tableName", type: macro: String}, {name: "fieldName", type: macro: String}, {name: "records", type: macro: Array<$complexType>}], macro: js.lib.Promise<Array<$complexType>>, [APrivate]);
        buildLinksFn.add(macro {
            return new js.lib.Promise((resolve, reject) -> {
                core.data.dao.Logger.instance.log(db.name + "." + $v{tableName} + " building links for " + $v{tableName} + "." + fieldName + " == " + tableName + "." + fieldName);
                var table = db.getTable(tableName);
                table.fetch().then(function(linkObjects) {
                    for (record in records) {
                        for (linkObject in linkObjects) {
                            if (linkObject.getFieldValue(fieldName) == record.getFieldValue(fieldName)) {
                                record.setLinkObject(fieldName, linkObject);
                            }
                        }
                    }
                    resolve(records);
                }).catchError(function(e) {
                    core.data.dao.Logger.instance.error("" + db.name + "." + $v{tableName} + " failed to retrieve data during linking to " + db.name + "." + tableName + " (" + e + ")");
                    reject(e);
                });
            });
        });
        
        //////////////////////////////////////////////////////////////////////////////////////////////
        
        var initFn = builder.addFunction("init", null, null, macro: js.lib.Promise<Bool>);
        initFn.add(macro {
            return new js.lib.Promise((resolve, reject) -> {
                if (this.info != null) {
                    core.data.dao.Logger.instance.log("" + db.name + "." + $v{tableName} + " already initialized, returning");
                    resolve(true);
                    return;
                }
                core.data.dao.Logger.instance.log(db.name + "." + $v{tableName} + " initializing");
                db.create().then(function(r) {
                    core.data.internal.CoreData.hasTable(db.name, $v{tableName}).then(function(hasTable) {
                        if (hasTable == false) {
                            core.data.dao.Logger.instance.log(db.name + "." + $v{tableName} + " does not exist, creating");
                            create().then(function(createResult) {
                                resolve(true);
                            }).catchError(function(e) {
                                core.data.dao.Logger.instance.error("" + db.name + "." + $v{tableName} + " failed to create table during initialization (" + e + ")");
                                reject(e);
                            });
                        } else {
                            core.data.dao.Logger.instance.log("" + db.name + "." + $v{tableName} + " exists, continuing");
                            core.data.internal.CoreData.getTableInfo(db.name, $v{tableName}).then(function(tableInfo) {
                                resolve(true);
                                this.info = tableInfo;
                            }).catchError(function(e) {
                                core.data.dao.Logger.instance.error("" + db.name + "." + $v{tableName} + " failed to retrieve table info (" + e + ")");
                                reject(e);
                            });
                        }
                    }).catchError(function(e) {
                        core.data.dao.Logger.instance.error("" + db.name + "." + $v{tableName} + " failed to initialize (" + e + ")");
                        reject(e);
                    });
                });
            });
        });
        
        //////////////////////////////////////////////////////////////////////////////////////////////

        var createFn = builder.addFunction("create", null, null, macro: js.lib.Promise<Bool>);
        createFn.add(macro {
            return new js.lib.Promise((resolve, reject) -> {
                db.create().then(function(r) {
                    core.data.dao.Logger.instance.log("" + db.name + "." + $v{tableName} + " creating table");
                    var fieldDefs = $i{typeName}.FieldDefinitions;
                    core.data.internal.CoreData.createTable(db.name, $v{tableName}, fieldDefs).then(function(createTableResult) {
                        addDefaultData().then(function(r) {
                            core.data.dao.Logger.instance.log("" + db.name + "." + $v{tableName} + " table created");
                            core.data.internal.CoreData.getTableInfo(db.name, $v{tableName}).then(function(tableInfo) {
                                this.info = tableInfo;
                                resolve(true);
                            }).catchError(function(e) {
                                core.data.dao.Logger.Logger.instance.error("" + db.name + "." + $v{tableName} + " failed to retrieve table info (" + e + ")");
                                reject(e);
                            });
                        });
                    }).catchError(function(e) {
                        core.data.dao.Logger.instance.error("" + db.name + "." + $v{tableName} + " failed to create table (" + e + ")");
                        reject(e);
                    });
                });
            });
        });
        
        //////////////////////////////////////////////////////////////////////////////////////////////

        builder.addVar("batchSize", macro: Int, macro 5000);
        var addObjectsFn = builder.addFunction("addObjects", null, [{name: "objects", type: macro: Array<$complexType>}, {name: "onProgress", type: macro: Int->Int->Void, value: macro null}], macro: js.lib.Promise<Bool>);
        addObjectsFn.add(macro {
            return new js.lib.Promise((resolve, reject) -> {
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
                
                core.data.dao.Logger.instance.log("" + db.name + "." + $v{tableName} + " adding " + objects.length + " objects in " + batches.length + " batches of " + batchSize); 
                processBatches(batches, function() {
                    resolve(true);
                }, onProgress, 0, batches.length);
            });
        });

        var processBatchesFn = builder.addFunction("processBatches", null, [{name: "batches", type: macro: Array<Array<Array<String>>>}, {name: "onComplete", type: macro: Void->Void}, {name: "onProgress", type: macro: Int->Int->Void}, {name: "current", type: macro: Int}, {name: "max", type: macro: Int}], null, [APrivate]);
        processBatchesFn.add(macro {
            if (batches.length == 0) {
                onComplete();
                return;
            }
            
            if (onProgress != null) {
                onProgress(current + 1, max);
            }
            
            var batch = batches.shift();
            core.data.dao.Logger.instance.log("" + db.name + "." + $v{tableName} + " processing batch " + (current + 1) + " of " + max + " (" + batch.length + " items)"); 
            core.data.internal.CoreData.addTableData(db.name, $v{tableName}, batch).then(function(batchResult) {
                processBatches(batches, onComplete, onProgress, current + 1, max);
            });
        });
        
        //////////////////////////////////////////////////////////////////////////////////////////////

        if (builder.hasFunction("addDefaultData") == false) {
            var addDefaultDataFn = builder.addFunction("addDefaultData", null, null, macro: js.lib.Promise<Bool>);
            addDefaultDataFn.add(macro {
                return new js.lib.Promise((resolve, reject) -> {
                    resolve(true);
                });
            });
        }

        return builder.fields;
    }
    
    private static function toFieldType(t:ComplexType) {
        switch (t) {
            case TPath(p):
                if (p.name == "Int" || p.name == "Float") {
                    return macro core.data.internal.CoreData.FieldType.Number;
                } else if (p.name == "String") {
                    return macro core.data.internal.CoreData.FieldType.String;
                } else if (p.name == "Bool") {
                    return macro core.data.internal.CoreData.FieldType.Boolean;
                }
            case _:    
                return macro core.data.internal.CoreData.FieldType.String;
        }
        return macro core.data.internal.CoreData.FieldType.Unknown;
    }
}