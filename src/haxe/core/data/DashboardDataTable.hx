package core.data;

import core.data.DashboardData;
import core.data.DashboardGroupData;
import core.data.dao.IDataTable;
import js.lib.Promise;

@:build(core.data.dao.Macros.buildDataTable(DashboardData))
class DashboardDataTable implements IDataTable<DashboardData> {
    public function getDashboardsByGroup():Promise<Map<DashboardGroupData, Array<DashboardData>>> {
        return new Promise((resolve, reject) -> {
            fetch().then(function(dashboards) {
                var map:Map<DashboardGroupData, Array<DashboardData>> = [];
                for (d in dashboards) {
                    var list = map.get(d.group);
                    if (list == null) {
                        list = [];
                        map.set(d.group, list);
                    }
                    list.push(d);
                }
                resolve(map);
            });
        });
    }
}