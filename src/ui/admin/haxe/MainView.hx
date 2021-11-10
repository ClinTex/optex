package;

import haxe.ui.components.Spacer;
import haxe.ui.components.Label;
import haxe.ui.components.Link;
import haxe.ui.components.Image;
import core.dashboards.Portlet;
import haxe.ui.containers.HBox;
import haxe.ui.containers.Box;
import haxe.ui.containers.Card;
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
        ComponentClassMap.instance.registerClassName("box", Type.getClassName(Box));
        ComponentClassMap.instance.registerClassName("portlet", Type.getClassName(Portlet));
        ComponentClassMap.instance.registerClassName("card", Type.getClassName(Card));
        ComponentClassMap.instance.registerClassName("image", Type.getClassName(Image));
        ComponentClassMap.instance.registerClassName("link", Type.getClassName(Link));
        ComponentClassMap.instance.registerClassName("label", Type.getClassName(Label));
        ComponentClassMap.instance.registerClassName("spacer", Type.getClassName(Spacer));

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
