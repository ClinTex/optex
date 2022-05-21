package core.components;

import core.data.PageData;
import core.data.PortletInstancePortletData;
import core.data.PortletInstanceLayoutData;
import core.components.portlets.PortletInstance;
import core.components.portlets.PortletEvent;
import core.components.portlets.PortletContainer;
import haxe.ui.RuntimeComponentBuilder;
import haxe.ui.containers.Box;
import core.data.InternalDB;
import core.components.portlets.PortletFactory;
import haxe.ui.containers.dialogs.Dialog.DialogEvent;
import core.components.dialogs.SelectPortletDialog;
import core.components.portlets.PortletFactory;

class PageLayout extends Page {
    public function new() {
        super();
        //registerEvent(PortletEvent.ASSIGN_PORTLET_CLICKED, onPortletAssignPortletClicked);
    }

    private function onPortletAssignPortletClicked(event:PortletEvent) {
        var portletContainer = event.portletContainer;
        var portletContainerId:String = portletContainer.id;

        var dialog = new SelectPortletDialog();
        dialog.onDialogClosed = function(e:DialogEvent) {
            if (e.button == "Select") {
                var selectedClassName = dialog.portletTypeSelector.selectedItem.className;

                var portletInstance = PortletFactory.instance.createInstance(selectedClassName);
                assignPortletInstance(portletContainerId, portletInstance);
            }
        }
        dialog.show();

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

        removeAllPortlets();
        removeAllComponents();

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

        _portletContainers.push(portletContainer);
        portletInstance.autoConfigure().then(function(r) {
            preloadPortletInstance(portletInstance).then(function(e) {
                portletContainer.portletInstance = portletInstance;
                portletContainer.registerEvent(PortletEvent.PORTLET_CONFIG_CHANGED, onPortletConfigChanged);
                var newEvent = new PortletEvent(PortletEvent.PORTLET_ASSIGNED);
                newEvent.portletContainer = portletContainer;
                dispatch(newEvent);
            });
        });
    }

    public function removeAllPortlets() {
        for (container in _portletContainers) {
            container.portletInstance = null;
        }
    }

    private function onPortletConfigChanged(event:PortletEvent) {
        dispatch(event);
    }

    public function loadPage(pageId:Int) {
        pageDetails = InternalDB.pages.utils.page(pageId);
        if (pageDetails != null) {
            assignPortletInstancesFromPage(pageId);
        }
    }

    public function assignPortletInstancesFromPage(pageId:Int) {
        for (portletDetails in InternalDB.pages.utils.portletInstances(pageId)) {
            assignPortletFromStringData(portletDetails.portletData, portletDetails.layoutData);
        }
    }

    public function assignPortletFromStringData(portletDataSting:String, layoutDataString:String) {
        var instanceData = PortletInstancePortletData.fromJsonString(portletDataSting);
        var layoutData = PortletInstanceLayoutData.fromJsonString(layoutDataString);
        assignPortletFromData(instanceData, layoutData);
    }

    public function assignPortletFromObjectData(portletDataObject:Dynamic, layoutDataObject:Dynamic) {
        var instanceData = PortletInstancePortletData.fromJsonObject(portletDataObject);
        var layoutData = PortletInstanceLayoutData.fromJsonObject(layoutDataObject);
        assignPortletFromData(instanceData, layoutData);
    }

    public function assignPortletFromData(instanceData:PortletInstancePortletData, layoutData:PortletInstanceLayoutData) {
        var portletInstance = PortletFactory.instance.createInstance(instanceData.portletClassName);
        portletInstance.instanceData = instanceData;
        portletInstance.layoutData = layoutData;
        assignPortletInstance(layoutData.portletContainerId, portletInstance);
    }

    private var _portletContainers:Array<PortletContainer> = [];
    public var portletContainers(get, null):Array<PortletContainer>;
    private function get_portletContainers():Array<PortletContainer> {
        return _portletContainers;
    }

    private function applyEditable() {
        var portletContainers = findComponents(PortletContainer, -1);
        for (portletContainer in portletContainers) {
            portletContainer.editable = _editable;
            portletContainer.registerEvent(PortletEvent.ASSIGN_PORTLET_CLICKED, onPortletAssignPortletClicked);
        }
    }
}