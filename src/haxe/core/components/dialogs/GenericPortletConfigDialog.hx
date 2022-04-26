package core.components.dialogs;

import core.components.portlets.PortletConfigPage;
import haxe.ui.containers.dialogs.Dialog;

@:build(haxe.ui.ComponentBuilder.build("core/assets/ui/dialogs/generic-portlet-config.xml"))
class GenericPortletConfigDialog extends Dialog {
    private var _configPages:Array<PortletConfigPage> = [];

    public function new() {
        super();
        buttons = DialogButton.CANCEL | DialogButton.APPLY;
    }

    private override function onReady() {
        super.onReady();

        _configPages.reverse();
        for (configPage in _configPages) {
            mainTabs.addComponentAt(configPage, 0);
        }
        mainTabs.pageIndex = 0;
    }

    public function addConfigPage(configPage:PortletConfigPage) {
        if (configPage == null) {
            return;
        }
        _configPages.push(configPage);
    }
}