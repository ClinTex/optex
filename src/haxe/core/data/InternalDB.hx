package core.data;

import js.lib.Promise;
import core.data.dao.Database;
import core.data.utils.PromiseUtils;

class InternalDB extends Database {
    private static var _instance:InternalDB = null;
    public static var instance(get, null):InternalDB;
    private static function get_instance():InternalDB {
        if (_instance == null) {
            _instance = new InternalDB();
        }
        return _instance;
    }

    public var dashboardData:DashboardDataTable;
    public var dashboardGroupData:DashboardGroupDataTable;
    public var iconData:IconDataTable;
    
    public function new() {
        super();
        
        name = "__optex_data";
        
        dashboardData = new DashboardDataTable();
        dashboardGroupData = new DashboardGroupDataTable();
        iconData = new IconDataTable();
        
        registerTable(DashboardDataTable.TableName, dashboardData);
        registerTable(DashboardGroupDataTable.TableName, dashboardGroupData);
        registerTable(IconDataTable.TableName, iconData);
    }

    public function init():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            var promises = [dashboardData.init(), dashboardGroupData.init(), iconData.init()];

            PromiseUtils.runSequentially(promises, function() {
                resolve(true);
            });
        });
    }
}