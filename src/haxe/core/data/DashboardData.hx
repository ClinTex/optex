package core.data;

import core.data.dao.IBuiltDataObject;

class DashboardData implements IBuiltDataObject {
    @:field(primary)            public var dashboardId:Int;
    @:field                     public var name:String;
    @:field                     public var order:Int;
    @:field                     public var layoutData:String;
    @:field                     public var iconId:Int;
    @:field                     public var dashboardGroupId:Int;
    
    @:link(dashboardGroupId)    public var group:DashboardGroupData;
    @:link(iconId)              public var icon:IconData;
}