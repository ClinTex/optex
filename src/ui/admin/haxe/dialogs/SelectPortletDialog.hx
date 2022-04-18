package dialogs;

import haxe.ui.containers.dialogs.Dialog;

@:build(haxe.ui.ComponentBuilder.build("assets/dialogs/select-portlet.xml"))
class SelectPortletDialog extends Dialog {
    public function new() {
        super();
        buttons = DialogButton.CANCEL | "Select";
    }
}