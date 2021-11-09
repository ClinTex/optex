package core.data;

import js.lib.Promise;
import core.data.CoreData.CoreResult;

class Dashboard {
    public var name:String;
    public var layoutData:String = null;
    public var icon:String = null;

    public function new (name:String) {
        this.name = name;
    }

    public function update():Promise<CoreResult> {
        return new Promise((resolve, reject) -> {
            if (icon == null) { 
                icon = "";
            }
            var data = [
                name,
                layoutData,
                icon
            ];
            CoreData.updateTableData(DatabaseManager.instance.internalData.name, DatabaseManager.instance.dashboardsData.name, "dashboardName", name, data).then(function (r) {
                resolve(r);
            });
        });
    }
}