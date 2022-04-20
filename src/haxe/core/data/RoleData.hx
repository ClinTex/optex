package core.data;

import core.data.dao.IBuiltDataObject;

class RoleData implements IBuiltDataObject {
    @:autoIncrement @:field(primary)    public var roleId:Int;
    @:field                             public var name:String;
    @:field                             public var organizationId:Int;
}