package dialogs;

import core.data.UserData;
import core.data.InternalDB;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.containers.dialogs.Dialog;

@:build(haxe.ui.ComponentBuilder.build("assets/dialogs/select-user.xml"))
class SelectUserDialog extends Dialog {
    public var selectedUser:UserData = null;
    public function new() {
        super();
        buttons = DialogButton.CANCEL | "Select";
        populate();
    }

    private function populate() {
        var ds = new ArrayDataSource<Dynamic>();
        for (user in InternalDB.users.data) {
            var userLabel = user.username + " (" + user.firstName + " " + user.lastName + ")";
            ds.add({
                icon: "themes/optex/user-solid.png",
                text: userLabel,
                user: user
            });
        }
        userList.dataSource = ds;
    }

    private override function validateDialog(button:DialogButton, cb:Bool->Void) {
        selectedUser = null;
        if (button == "Select" && userList.selectedItem.user != null) {
            selectedUser = userList.selectedItem.user;
        }
        cb(true);
    }
}