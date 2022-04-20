package core.data;

import core.data.dao.IBuiltDataObject;

class UserData implements IBuiltDataObject {
    @:autoIncrement @:field(primary)    public var userId:Int;
    @:field                             public var username:String;
    @:field                             public var password:String;
    @:field                             public var firstName:String;
    @:field                             public var lastName:String;
    @:field                             public var emailAddress:String;
    @:field                             public var isAdmin:Bool;
}