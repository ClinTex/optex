package core.data;

import core.data.dao.IBuiltDataObject;

class UserGroupRoleLinkData implements IBuiltDataObject {
    @:field(primary)            public var userGroupId:Int;
    @:field                     public var roleId:Int;
}