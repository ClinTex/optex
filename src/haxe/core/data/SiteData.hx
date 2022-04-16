package core.data;

import core.data.dao.IBuiltDataObject;

class SiteData implements IBuiltDataObject {
    @:field(primary)            public var siteId:Int;
    @:field                     public var organizationId:Int;
    @:field                     public var name:String;
}
