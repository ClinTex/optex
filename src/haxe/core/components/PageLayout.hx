package core.components;

import core.data.PortletInstancePortletData;
import core.data.PortletInstanceLayoutData;
import core.components.portlets.PortletInstance;
import core.components.portlets.PortletEvent;
import core.components.portlets.PortletContainer;
import haxe.ui.RuntimeComponentBuilder;
import haxe.ui.containers.Box;
import core.data.InternalDB;
import core.components.portlets.PortletFactory;

class PageLayout extends Page {
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
        if (portletContainer == null) {
            trace("WARNING: could not find portlet container with an id of: " + portletContainerId);
            return;
        }

        preloadPortletInstance(portletInstance).then(function(e) {
                portletContainer.portletInstance = portletInstance;
        });
    }

    public function assignPortletInstancesFromPage(pageId:Int) {
        for (portletDetails in InternalDB.pages.utils.portletInstances(pageId)) {
            var instanceData = PortletInstancePortletData.fomJsonString(portletDetails.portletData);
            var layoutData = PortletInstanceLayoutData.fomJsonString(portletDetails.layoutData);
            var portletInstance = PortletFactory.instance.createInstance(instanceData.portletClassName);
            portletInstance.instanceData = instanceData;
            portletInstance.layoutData = layoutData;
            assignPortletInstance(layoutData.portletContainerId, portletInstance);
        }
    }

    public var portletContainers(get, null):Array<PortletContainer>;
    private function get_portletContainers():Array<PortletContainer> {
        var containers = findComponents(PortletContainer, -1);
        return containers;
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