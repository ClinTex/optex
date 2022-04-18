package core.components.dialogs;

import haxe.ui.containers.dialogs.Dialog;

@:build(haxe.ui.ComponentBuilder.build("core/assets/ui/dialogs/generic-portlet-config.xml"))
class GenericPortletConfigDialog extends Dialog {
    public function new() {
        super();
        buttons = DialogButton.CANCEL | DialogButton.APPLY;
    }
}