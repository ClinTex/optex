package core.components;

import core.components.portlets.PortletInstance;
import core.components.portlets.PortletEvent;
import core.components.portlets.PortletContainer;
import haxe.ui.RuntimeComponentBuilder;
import haxe.ui.containers.Box;

class PageLayout extends Box {
    public function new() {
        super();
    }

    private var _layoutData:String = null;
    public var layoutData(get, set):String;
    private function get_layoutData():String {
        return _layoutData;
    }
    private function set_layoutData(value:String):String {
        if (_layoutData == value) {
            return value;
        }

        _layoutData = value;
        var c = RuntimeComponentBuilder.fromString(_layoutData);
        addComponent(c);
        applyEditable();

        return value;
    }

    private var _editable:Bool = false;
    public var editable(get, set):Bool;
    private function get_editable():Bool {
        return _editable;
    }
    private function set_editable(value:Bool):Bool {
        _editable = value;
        applyEditable();
        return value;
    }

    public function assignPortletInstance(portletContainerId:String, portletInstance:PortletInstance) {
        var portletContainer = findComponent(portletContainerId, PortletContainer);
        portletContainer.portletInstance = portletInstance;
    }

    private function applyEditable() {
        var portletContainers = findComponents(PortletContainer, -1);
        for (portletContainer in portletContainers) {
            portletContainer.editable = _editable;
            portletContainer.registerEvent(PortletEvent.ASSIGN_PORTLET_CLICKED, onPortletAssignPortletClicked);
        }
    }

    private function onPortletAssignPortletClicked(event:PortletEvent) {
        dispatch(event);
    }
}