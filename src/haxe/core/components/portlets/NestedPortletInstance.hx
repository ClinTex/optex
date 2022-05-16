package core.components.portlets;

import core.data.PortletInstancePortletData;
import core.data.LayoutData;
import haxe.ui.events.UIEvent;
import haxe.ui.components.Label;
import haxe.ui.data.ArrayDataSource;
import core.data.InternalDB;
import core.components.portlets.PortletEvent;
import js.lib.Promise;

class NestedPortletInstance extends PortletInstance {
    private var _layoutId:Null<Int> = null;
    private var _pageLayout:PageLayout = null;

    public function new() {
        super();
        configureControlsHorizontalAlign = "left";
        configureControlsVerticalAlign = "bottom";
    }

    private override function onReady() {
        super.onReady();
    }

    public override function autoConfigure():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            if (instanceData == null) {
                instanceData = new PortletInstancePortletData();
            }
            if (instanceData.getIntValue("layoutId") == null) {
                instanceData.setValue("layoutId", 1);
            }
            resolve(true);
        });
    }

    public override function initPortlet() {
        super.initPortlet();

        _layoutId = getConfigIntValue("layoutId");
        if (_pageLayout != null) {
            removeComponent(_pageLayout);
        }
        _pageLayout = new PageLayout();
        _pageLayout.pageDetails = this.page.pageDetails;
        _pageLayout.percentWidth = 100;
        _pageLayout.percentHeight = 100;
        _pageLayout.registerEvent(PortletEvent.PORTLET_ASSIGNED, onPortletAssigned);
        _pageLayout.registerEvent(PortletEvent.PORTLET_CONFIG_CHANGED, onPortletConfigChanged);
        addComponent(_pageLayout);
    }

    private function onPortletAssigned(event:PortletEvent) {
        var portletContainer = event.portletContainer;
        trace("===================== PORTLET ASSIGNED =======================");
        trace(portletContainer.portletInstance.instanceData);
        trace(portletContainer.portletInstance.layoutData);
        writePortletConfig();
    }

    private function onPortletConfigChanged(event:PortletEvent) {
        var portletContainer = event.portletContainer;
        trace("===================== PORTLET CONFIG CHANGED =======================");
        trace(portletContainer.portletInstance.instanceData);
        trace(portletContainer.portletInstance.layoutData);
        writePortletConfig();
    }

    private function writePortletConfig() {
        trace("==============================>>>>>>>>>>>>>>>>>>>>>>>>> " + _pageLayout.portletContainers.length);
        var portlets:Array<Dynamic> = [];
        for (portletContainer in _pageLayout.portletContainers) {
            trace(portletContainer.portletInstance.instanceData, portletContainer.portletInstance.layoutData);
            portlets.push({
                layoutData: portletContainer.portletInstance.layoutData.data,
                portletData: portletContainer.portletInstance.instanceData.data
            });
        }
        instanceData.setValue("portlets", portlets);
    }

    public override function refreshView() {
        if (_layoutId == null) {
            return;
        }

        var layoutDetails = InternalDB.layouts.utils.layout(_layoutId);
        trace(layoutDetails.layoutData);
        _pageLayout.layoutData = layoutDetails.layoutData;
        _pageLayout.editable = true;

        var portlets:Array<Dynamic> = instanceData.getObjectValue("portlets");
        if (portlets != null) {
            for (porlet in portlets) {
                var portletData = porlet.portletData;
                var layoutData = porlet.layoutData;
                _pageLayout.assignPortletFromObjectData(portletData, layoutData);
            }
        }
    }

    private override function get_configPage():PortletConfigPage {
        var configPage = new NestedPortletConfigPage();
        return configPage;
    }
}

@:build(haxe.ui.ComponentBuilder.build("core/assets/ui/portlets/config-pages/nested-portlets-config-page.xml"))
private class NestedPortletConfigPage extends PortletConfigPage {
    public function new() {
        super();
    }

    private override function onReady() {
        super.onReady();

        var ds = new ArrayDataSource<Dynamic>();
        var indexToSelect = 0;
        var n = 0;
        var layoutId = portletData.getIntValue("layoutId");
        for (layout in InternalDB.layouts.utils.availableLayoutsForPage(this.page.pageDetails.pageId)) {
            if (layoutId != null && layout.layoutId == layoutId) {
                indexToSelect = n;
            }
            ds.add({
                text: layout.name,
                layout: layout
            });
            n++;
        }
        layoutSelector.dataSource = ds;
        layoutSelector.selectedIndex = indexToSelect;
    }

    @:bind(layoutSelector, UIEvent.CHANGE)
    private function onLayoutSelectorChange(_) {
        if (layoutSelector.selectedItem == null) {
            return;
        }
        var selectedLayout:LayoutData = layoutSelector.selectedItem.layout;
        portletData.setValue("layoutId", selectedLayout.layoutId);
        dispatchPortletConfigChanged();
    }
}