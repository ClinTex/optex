package dialogs;

import haxe.ui.containers.dialogs.Dialog;

@:build(haxe.ui.ComponentBuilder.build("assets/dialogs/login.xml"))
class LoginDialog extends Dialog {
    public function new() {
        super();
        buttons = "Login";
    }
}