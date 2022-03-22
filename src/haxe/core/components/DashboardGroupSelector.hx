package core.components;

import core.data.InternalDB;
import haxe.ui.components.DropDown;
import haxe.ui.data.ArrayDataSource;

class DashboardGroupSelector extends DropDown {
    public function new() {
        super();
        var ds = new ArrayDataSource<Dynamic>();
        for (group in InternalDB.dashboardGroups.data) {
            ds.add({
                text: group.name,
                groupData: group
            });
        }
        this.dataSource = ds;
    }
}