package core.components.portlets;

import core.data.PortletInstancePortletData;
import core.data.PortletInstanceLayoutData;
import core.data.PortletInstanceData;

class PortletInstance extends Portlet {
    public var instanceData:PortletInstancePortletData;
    public var layoutData:PortletInstanceLayoutData;

    private override function onReady() {
        super.onReady();
        this.percentWidth = 100;
    }

    private var _portletDetails:PortletInstanceData;
    public var portletDetails(get, set):PortletInstanceData;
    private function get_portletDetails():PortletInstanceData {
        if (_portletDetails == null) {
            _portletDetails = new PortletInstanceData();
        }

        _portletDetails.portletData = PortletInstancePortletData.toJsonString(instanceData);
        _portletDetails.layoutData = PortletInstanceLayoutData.toJsonString(layoutData);

        return _portletDetails;
    }
    private function set_portletDetails(value:PortletInstanceData):PortletInstanceData {
        _portletDetails = value;
        instanceData = PortletInstancePortletData.fomJsonString(_portletDetails.portletData);
        layoutData = PortletInstanceLayoutData.fomJsonString(_portletDetails.layoutData);
        return value;
    }

    public function initPortlet() {

    }

    public function refreshView() {

    }

    private function getConfigValue(name:String, defaultValue:String = null):String {
        return instanceData.getStringValue(name, defaultValue);
    }

    private function getConfigIntValue(name:String, defaultValue:Null<Int> = null):Null<Int> {
        return instanceData.getIntValue(name, defaultValue);
    }

    private function getConfigBoolValue(name:String, defaultValue:Null<Bool> = false):Null<Bool> {
        return instanceData.getBoolValue(name, defaultValue);
    }

    public var page(get, null):Page;
    private function get_page():Page {
        var p = findAncestor(Page);
        return p;
    }

    public var configPage(get, null):PortletConfigPage;
    private function get_configPage():PortletConfigPage {
        return null;
    }
}
