package;

import dialogs.PermissionCheckerDialog;
import core.data.UserData;
import haxe.ui.events.UIEvent;
import dialogs.TransformBrowserDialog;
import views.DataView;
import haxe.ui.containers.menus.Menu.MenuEvent;
import haxe.ui.containers.VBox;

@:build(haxe.ui.ComponentBuilder.build("assets/main-view.xml"))
class AdminView extends VBox {
    public static var instance:AdminView = null;

    public var currentUser:UserData = new UserData();

    public function new() {
        super();

        instance = this;

        currentUser.firstName = "Ian";
        currentUser.lastName = "Harrigan";
        currentUser.isAdmin = true;
        var userLabel =  currentUser.firstName + " " + currentUser.lastName;
        if (currentUser.isAdmin) {
            userLabel += " (Admin)";
        }
        userMenu.text = userLabel;

    }

    @:bind(mainMenu, MenuEvent.MENU_SELECTED)
    private function onMenuMenu(e:MenuEvent) {
        switch (e.menuItem.id) {
            case "removeCurrentDatabase":
                DataView.instance.removeCurrentDatabase();
            case "clearAll":
                clearAllDbs();
            case "transformBrowser":
                var dialog = new TransformBrowserDialog();
                dialog.show();
            case "permissionChecker":
                var dialog = new PermissionCheckerDialog();
                dialog.show();
        }
    }

    private function clearAllDbs() {
        /*
        var working = new WorkingIndicator();
        working.showWorking();
        DatabaseManager.instance.removeDatabase("ClintexPrimaryData").then(function(r) {
            DatabaseManager.instance.removeDatabase("__optex_internal_data").then(function(r) {
                working.workComplete();
            });
            
        });
        */
    }

    @:bind(mainStack, UIEvent.CHANGE)
    private function onMainStackChanged(_) {
        mainButtons.selectedIndex = mainStack.selectedIndex;
    }

    public function changeView(id:String) {
        mainStack.selectedId = id;
    }
}