package core.components;

import core.data.InternalDB;
import haxe.ui.components.DropDown;
import haxe.ui.data.ArrayDataSource;

class IconSelector extends DropDown {
    public function new() {
        super();
        var ds = new ArrayDataSource<Dynamic>();
        for (icon in InternalDB.icons.data) {
            ds.add({
                text: icon.name,
                icon: "themes/optex/" + icon.path,
                iconData: icon
            });
        }
        this.dataSource = ds;
    }
}