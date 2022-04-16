package core.data;

import core.data.dao.IBuiltDataObject;

class PageData implements IBuiltDataObject {
    @:field(primary)            public var pageId:Int;
    @:field                     public var parentPageId:Int;
    @:field                     public var siteId:Int;
    @:field                     public var layoutId:Int;
    @:field                     public var iconId:Int;
    @:field                     public var name:String;
}
