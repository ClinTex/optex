package core.data;

import core.data.dao.IBuiltDataObject;

class DashboardGroupData implements IBuiltDataObject {
    @:field(primary)    public var dashboardGroupId:Int;
    @:field             public var name:String;
    @:field             public var order:Int;
    @:field             public var iconId:Int;
    
    @:link(iconId)      public var icon:IconData;
}