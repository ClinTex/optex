package;

import haxe.ui.data.ArrayDataSource;
import haxe.ui.containers.VBox;
import haxe.ui.events.MouseEvent;
import core.data.CoreData;
import core.data.DataSourceManager;
import core.data.DataSource;

@:build(haxe.ui.ComponentBuilder.build("assets/main-view.xml"))
class MainView extends VBox {
    public function new() {
        super();
    }
}