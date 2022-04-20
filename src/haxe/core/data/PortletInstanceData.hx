package core.data;

import core.data.dao.IBuiltDataObject;

class PortletInstanceData implements IBuiltDataObject {
    @:autoIncrement @:field(primary)    public var portletInstanceId:Int;
    @:field                             public var pageId:Int;
    @:field                             public var portletData:String;
    @:field                             public var layoutData:String;
}
