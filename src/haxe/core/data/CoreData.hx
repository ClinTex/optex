package core.data;

import js.lib.Promise;

typedef CoreResult = {
    var errored:Bool;
    var errorCode:Int;
    var errorText:String;
}

typedef DatabaseInfo = {
    var databaseName:String;
    var tables:Array<TableInfo>;
}

typedef TableInfo = {
    var tableName:String;
    var fieldDefinitions:Array<TableFieldInfo>;
    var recordCount:Int;
}

typedef TableFieldInfo = {
    var fieldName:String;
    var fieldType:Int;
}

class FieldType {
    public static inline var Unknown:Int = 0;
    public static inline var String:Int = 1;
    public static inline var Number:Int = 2;
    public static inline var Boolean:Int = 3;

    public static function toString(v:Int):String {
        switch (v) {
            case String:
                return "string";
            case Number:
                return "number";
            case Boolean:
                return "boolean";
        }
        return "unknown";
    }

    public static function fromString(v:String):Int {
        switch (v) {
            case "string":
                return String;
            case "number":
                return Number;
            case "boolean":
                return Boolean;
        }
        return Unknown;
    }
}

typedef TableFragment = {
    var fieldDefinitions:Array<TableFieldInfo>;
    var data:Array<Array<String>>;
    var total:Int;
    var count:Int;
}

@:native("core_data")
extern class CoreData {
    static function listDatabases():Promise<Array<DatabaseInfo>>;

    static function createDatabase(databaseName:String):Promise<CoreResult>;
    static function removeDatabase(databaseName:String):Promise<CoreResult>;
    static function hasDatabase(databaseName:String):Promise<Bool>;
    static function getDatabaseInfo(databaseName:String):Promise<DatabaseInfo>;

    static function hasTable(databaseName:String, tableName:String):Promise<Bool>;
    static function createTable(databaseName:String, tableName:String, fieldDefinitions:Array<TableFieldInfo>):Promise<CoreResult>;
    static function removeTable(databaseName:String, tableName:String):Promise<CoreResult>;
    static function getTableInfo(databaseName:String, tableName:String):Promise<TableInfo>;

    static function addTableData(databaseName:String, tableName:String, data:Array<Array<String>>):Promise<CoreResult>;
    static function getTableData(databaseName:String, tableName:String, start:Int, end:Int):Promise<TableFragment>;
    static function updateTableData(databaseName:String, tableName:String, fieldName:String, fieldValue:String, newData:Array<String>):Promise<CoreResult>;

    static function applyTableTransform(databaseName:String, tableName:String, transformId:String, parameters:Array<Array<String>>):Promise<TableFragment>;
    static function test1(databaseName:String, tableName:String, fieldName:String):Promise<TableFragment>;
}
