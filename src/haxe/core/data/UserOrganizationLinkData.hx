package core.data;

import core.data.dao.IBuiltDataObject;

class UserOrganizationLinkData implements IBuiltDataObject {
    @:field(primary)        public var userId:Int;
    @:field                 public var organizationId:Int;
}