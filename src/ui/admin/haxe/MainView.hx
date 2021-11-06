package;

import core.dashboards.Portlet;
import haxe.ui.containers.HBox;
import haxe.ui.core.ComponentClassMap;
import core.data.DatabaseManager;
import views.DataView;
import haxe.ui.containers.menus.Menu.MenuEvent;
import haxe.ui.containers.VBox;

@:build(haxe.ui.ComponentBuilder.build("assets/main-view.xml"))
class MainView extends VBox {
    public function new() {
        super();

        ComponentClassMap.instance.registerClassName("vbox", Type.getClassName(VBox));
        ComponentClassMap.instance.registerClassName("hbox", Type.getClassName(HBox));
        ComponentClassMap.instance.registerClassName("portlet", Type.getClassName(Portlet));

        DatabaseManager.instance.init().then(function(r) {
            trace("database manager ready");
        });
    }
    
    @:bind(mainMenu, MenuEvent.MENU_SELECTED)
    private function onMenuMenu(e:MenuEvent) {
        switch (e.menuItem.id) {
            case "removeCurrentDatabase":
                DataView.instance.removeCurrentDatabase();
        }
    }
}
