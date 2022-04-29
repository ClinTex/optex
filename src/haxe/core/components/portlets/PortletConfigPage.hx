package core.components.portlets;

import core.data.PortletInstancePortletData;
import haxe.ui.containers.VBox;

class PortletConfigPage extends VBox {
    public var portletData:PortletInstancePortletData;

    public function new() {
        super();
    }

    private var _page:Page = null;
    public var page(get, set):Page;
    private function get_page():Page {
        return _page;
    }
    private function set_page(value:Page):Page {
        _page = value;
        return value;
    }
}