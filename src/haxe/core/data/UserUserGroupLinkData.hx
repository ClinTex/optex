package core.data;

import core.data.dao.IBuiltDataObject;

class UserUserGroupLinkData implements IBuiltDataObject {
    @:autoIncrement @:field(primary)    public var userId:Int;
    @:field                             public var userGroupId:Int;
}