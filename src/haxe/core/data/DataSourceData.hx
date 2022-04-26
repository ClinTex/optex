package core.data;

import core.data.dao.IBuiltDataObject;

class DataSourceData implements IBuiltDataObject {
    @:autoIncrement @:field(primary)    public var dataSourceId:Int;
    @:field                             public var databaseName:String;
    @:field                             public var tableName:String;
    @:field                             public var configData:String;
}