package core.data; 

import js.lib.Promise;

class DashboardManager {
    private static var _instance:DashboardManager = null;
    public static var instance(get, null):DashboardManager;
    private static function get_instance():DashboardManager {
        if (_instance == null) {
            _instance = new DashboardManager();
        }
        return _instance;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // INSTANCE
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    private function new() {
    }

    public function listDashboards(count:Int = 100):Promise<Array<Dashboard>> {
        return new Promise((resolve, reject) -> {
            DatabaseManager.instance.dashboardsData.getRows(0, count).then(function(fragment) {
                var dashboards:Array<Dashboard> = [];
                for (r in fragment.data) {
                    var dashboard = new Dashboard(r[0]);
                    dashboard.layoutData = r[1];
                    dashboards.push(dashboard);
                }
                resolve(dashboards);
            });
        });
    }

    public function createDashboard(dashboard:Dashboard):Promise<Bool> {
        return new Promise((resolve, reject) -> {
            var data = [dashboard.name, dashboard.layoutData];
            DatabaseManager.instance.dashboardsData.addData(data).commit().then(function(r) {
                resolve(true);
            });
        });
    }
}
