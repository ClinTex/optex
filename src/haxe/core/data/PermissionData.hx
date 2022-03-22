package core.data;

import core.data.dao.IBuiltDataObject;

class PermissionData implements IBuiltDataObject {
    @:field(primary)            public var permissionId:Int;
    @:field                     public var roleId:Int;
    @:field                     public var resourceId:Int;
    @:field                     public var resourceType:Int;
    @:field                     public var permissionAction:Int;
}