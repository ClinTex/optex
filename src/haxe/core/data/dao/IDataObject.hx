package core.data.dao;

import js.lib.Promise;

interface IDataObject {
    var primaryKey(get, set):Int;
    var primaryKeyName(get, null):String;

    function fromArray(data:Array<String>):Void;
    function toArray():Array<String>;
    function getFieldValue(fieldName:String):Any;
    function update():Promise<Bool>;
    function add():Promise<Bool>;
}