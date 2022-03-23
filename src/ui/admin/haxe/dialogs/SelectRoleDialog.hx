package dialogs;

import core.data.InternalDB;
import haxe.ui.data.ArrayDataSource;
import core.data.RoleData;
import haxe.ui.containers.dialogs.Dialog;

@:build(haxe.ui.ComponentBuilder.build("assets/dialogs/select-role.xml"))
class SelectRoleDialog extends Dialog {
    public var selectedRole:RoleData = null;
    public function new() {
        super();
        buttons = DialogButton.CANCEL | "Select";
        populate();
    }

    private function populate() {
        var ds = new ArrayDataSource<Dynamic>();
        for (role in InternalDB.roles.data) {
            ds.add({
                icon: "themes/optex/person-solid.png",
                text: role.name,
                role: role
            });
        }
        roleList.dataSource = ds;
    }

    private override function validateDialog(button:DialogButton, cb:Bool->Void) {
        selectedRole = null;
        if (button == "Select" && roleList.selectedItem.role != null) {
            selectedRole = roleList.selectedItem.role;
        }
        cb(true);
    }
}