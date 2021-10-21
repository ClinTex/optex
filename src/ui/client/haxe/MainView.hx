package;

import haxe.ui.containers.VBox;
import haxe.ui.events.MouseEvent;
import haxe.ui.containers.dialogs.Dialog.DialogEvent;
import haxe.ui.containers.dialogs.Dialog.DialogButton;
import haxe.ui.containers.dialogs.Dialogs;
import haxe.ui.containers.dialogs.MessageBox.MessageBoxType;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.util.Timer;

@:build(haxe.ui.ComponentBuilder.build("assets/main-view.xml"))
class MainView extends VBox {
    public function new() {
        super();
        refreshContacts();
        var timer = new Timer(100, function() {
            trace("refreshing");
            refreshContacts();
        });
    }

    private function refreshContacts() {
        var ds = new ArrayDataSource<Dynamic>();

        CoreData.listContacts().then(function(r) {
            for (c in r) {
                ds.add({
                    firstName: c.firstName,
                    lastName: c.lastName,
                    emailAddress: c.emailAddress,
                });
            }
            
            table.selectedIndex = -1;
            table.dataSource = ds;
        });
    }
}