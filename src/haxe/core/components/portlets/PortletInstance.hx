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
}