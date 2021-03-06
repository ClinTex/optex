package core.data;

import core.data.dao.IBuiltDataObject;

class UserGroupData implements IBuiltDataObject {
    @:autoIncrement @:field(primary)    public var userGroupId:Int;
    @:field                             public var name:String;
    @:field                             public var organizationId:Int;
}