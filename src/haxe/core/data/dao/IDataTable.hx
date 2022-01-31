package core.data.dao;

import js.lib.Promise;

typedef FetchParams = {
    @:optional var start:Null<Int>;
    @:optional var end:Null<Int>;
    @:optional var transformId:String;
    @:optional var transformParameters:Map<String, String>;
}

interface IDataTable<T> {
    var db:Database;
    var name:String;
    
    function init():Promise<Bool>;
    function create():Promise<Bool>;
    function fetch(params:FetchParams = null):Promise<Array<T>>;
    function updateObject(object:T):Promise<Bool>;
    function addObject(object:T):Promise<Bool>;
    function createObject(data:Array<Any> = null):T;
}