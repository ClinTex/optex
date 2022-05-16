package core.components.dialogs;

import haxe.ui.containers.dialogs.Dialog;

@:build(haxe.ui.ComponentBuilder.build("core/assets/ui/dialogs/select-portlet.xml"))
class SelectPortletDialog extends Dialog {
    public function new() {
        super();
        buttons = DialogButton.CANCEL | "Select";
    }
}