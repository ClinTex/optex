package;

import views.DataView;
import haxe.ui.containers.menus.Menu.MenuEvent;
import haxe.ui.containers.VBox;

@:build(haxe.ui.ComponentBuilder.build("assets/main-view.xml"))
class MainView extends VBox {
    public function new() {
        super();
    }
    
    @:bind(mainMenu, MenuEvent.MENU_SELECTED)
    private function onMenuMenu(e:MenuEvent) {
        switch (e.menuItem.id) {
            case "removeCurrentDatabase":
                DataView.instance.removeCurrentDatabase();
        }
    }
}
