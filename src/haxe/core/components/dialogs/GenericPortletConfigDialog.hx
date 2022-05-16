package core.components.dialogs;

import core.components.portlets.PortletEvent;
import core.components.portlets.PortletConfigPage;
import haxe.ui.containers.dialogs.Dialog;
import core.data.PortletInstancePortletData;
import haxe.ui.events.UIEvent;
import haxe.Json;

@:build(haxe.ui.ComponentBuilder.build("core/assets/ui/dialogs/generic-portlet-config.xml"))
class GenericPortletConfigDialog extends Dialog {
    private var _configPages:Array<PortletConfigPage> = [];

    public var portletData:PortletInstancePortletData;

    public function new() {
        super();
        buttons = DialogButton.CLOSE;

        portletConfigJsonField.onChange = function(_) {
            try {
                var json = Json.parse(portletConfigJsonField.text);
                portletData.data = json;
                dispatchPortletConfigChanged();
            } catch (e:Dynamic) {
            }
        }
    }

    private function dispatchPortletConfigChanged() {
        var event = new UIEvent(UIEvent.CHANGE);
        dispatch(event);

        var event = new PortletEvent(PortletEvent.PORTLET_CONFIG_CHANGED);
        event.data = portletData.data;
        dispatch(event);
    }

    private override function onReady() {
        super.onReady();

        _configPages.reverse();
        for (configPage in _configPages) {
            mainTabs.addComponentAt(configPage, 0);
        }
        mainTabs.pageIndex = 0;
    }

    @:bind(mainTabs, UIEvent.CHANGE)
    private function onMainTabsChange(_) {
        if (mainTabs.selectedPage.text == "JSON") {
            var prettyJson = Json.stringify(portletData.data, null, "  ");
            portletConfigJsonField.text = prettyJson;
        }
    }

    public function addConfigPage(configPage:PortletConfigPage) {
        if (configPage == null) {
            return;
        }
        configPage.page = page;
        configPage.portletData = portletData;
        _configPages.push(configPage);
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