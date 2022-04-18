package core.components.portlets;

import haxe.ui.events.UIEvent;

class PortletEvent extends UIEvent {
    public static inline var ASSIGN_PORTLET_CLICKED:String = "assignPortletClicked";
    public static inline var CONFIGURE_PORTLET_CLICKED:String = "configurePortletClicked";

    public var portletContainer:PortletContainer = null;

    public function new(type:String, bubble:Null<Bool> = false, data:Dynamic = null) {
        super(type, bubble, data);
    }
    
    public override function clone():PortletEvent {
        var c:PortletEvent = new PortletEvent(this.type);
        c.type = this.type;
        c.bubble = this.bubble;
        c.target = this.target;
        c.data = this.data;
        c.canceled = this.canceled;
        c.portletContainer = this.portletContainer;
        postClone(c);
        return c;
    }
}