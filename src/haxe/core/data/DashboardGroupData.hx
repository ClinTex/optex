package core.data;

import core.data.dao.IBuiltDataObject;

class DashboardGroupData implements IBuiltDataObject {
    @:field(primary)    public var dashboardGroupId:Int;
    @:field             public var name:String;
    @:field             public var order:Int;
    @:field             public var iconId:Int;
    @:field             public var organizationId:Int;
    @:field             public var creatorUserId:Int;
    
    @:link(iconId)      public var icon:IconData;
}