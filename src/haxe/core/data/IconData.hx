package core.data;

import core.data.dao.IBuiltDataObject;

class IconData implements IBuiltDataObject {
    @:autoIncrement @:field(primary)    public var iconId:Int;
    @:field                             public var name:String;
    @:field                             public var path:String;
}