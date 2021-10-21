package core;

typedef TFieldDefinition = {
    var fieldName:String;
    var fieldType:String;
}

typedef TDataSource = {
    var dataSourceName:String;
    var fieldDefinitions:Array<TFieldDefinition>;
    var data:Array<Array<Any>>;
}
