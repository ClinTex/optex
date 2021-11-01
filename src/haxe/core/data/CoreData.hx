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
    public static inline var Unknown = 0;
    public static inline var String = 1;
    public static inline var Number = 2;
    public static inline var Boolean = 3;
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

    static function addTableData(databaseName:String, tableName:String, data:Array<Array<String>>):Promise<CoreResult>;
    static function getTableData(databaseName:String, tableName:String, start:Int, end:Int):Promise<TableFragment>;
}
