package core.data;

import core.data.dao.IBuiltDataObject;

class OrganizationData implements IBuiltDataObject {
    @:field(primary)            public var organizationId:Int;
    @:field                     public var name:String;
}