package core.data;

import core.data.dao.IBuiltDataObject;

class LayoutData implements IBuiltDataObject {
    @:autoIncrement @:field(primary)    public var layoutId:Int;
    @:field                             public var organizationId:Int;
    @:field                             public var name:String;
    @:field                             public var layoutData:String;
}
