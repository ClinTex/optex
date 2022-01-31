package core.data.dao;

import js.lib.Promise;

interface IDataObject {
    function fromArray(data:Array<String>):Void;
    function toArray():Array<String>;
    function getFieldValue(fieldName:String):Any;
    function update():Promise<Bool>;
    function add():Promise<Bool>;
}