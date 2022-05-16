package core.components;

import core.data.DataSourceData;
import core.data.InternalDB;
import core.data.utils.PromiseUtils;
import core.components.portlets.PortletInstance;
import haxe.ui.containers.Box;
import js.lib.Promise;
import core.data.DatabaseManager;
import core.data.GenericTable;
import core.data.dao.Database;
import core.components.portlets.PortletDataUtils;
import core.data.PageData;

class Page extends Box {
    public var pageDetails:PageData;

    public function new() {
        super();
    }

    /*
    private var _databaseCache:Map<String, Database> = [];
    public function getDatabase(databaseName:String):Promise<Database> {
        return new Promise((resolve, reject) -> {
            if (_databaseCache.exists(databaseName)) {
                resolve(_databaseCache.get(databaseName));
                return;
            }

            DatabaseManager.instance.getDatabase(databaseName).then(function(db) {
                _databaseCache.set(databaseName, db);
                resolve(db);
            });
        });
    }

    private var _tableCache:Map<String, GenericTable> = [];
    public function fetchTableData(databaseName:String, tableName:String):Promise<GenericTable> {
        return new Promise((resolve, reject) -> {
            var key = databaseName + "." + tableName;
            if (_tableCache.exists(key)) {
                var table = _tableCache.get(key);
                var copy = table.clone(true);
                resolve(copy);
                return;
            }
            getDatabase(databaseName).then(function(db) {
                var table:GenericTable = cast db.getTable(tableName);
                table.fetch().then(function(_) {
                    var copy = table.clone(true);
                    _tableCache.set(key, copy);
                    resolve(copy);
                });
            });
        });
    }
    */

    public function getTableData(portletInstance:PortletInstance):Promise<GenericTable> {
        return new Promise((resolve, reject) -> {
            var dataSourceData:DataSourceData = InternalDB.dataSources.utils.dataSource(portletInstance.instanceData.dataSourceId);
            if (dataSourceData != null) {
                PortletDataUtils.fetchTableData(dataSourceData.databaseName, dataSourceData.tableName).then(function(unfilteredTable) {
                    // TODO: filter table here if required
                    if (portletInstance.instanceData.transform != null) {
                        unfilteredTable = unfilteredTable.transform(portletInstance.instanceData.transform , null);
                    }
                    resolve(unfilteredTable);
                });
            } else {
                resolve(null);
            }
        });
    }

    public function preloadPortletInstance(portletInstance:PortletInstance):Promise<Bool> {
        return new Promise((resolve, reject) -> {
            var promises = [];
            if (portletInstance.instanceData != null && portletInstance.instanceData.dataSourceId != null) {
                promises.push(preloadPortletDataSource(portletInstance));
            }

            PromiseUtils.runSequentially(promises, function() {
                resolve(true);
            });
        });
    }

    private function preloadPortletDataSource(portletInstance:PortletInstance):Promise<Bool> {
        return new Promise((resolve, reject) -> {
            var dataSourceData = InternalDB.dataSources.utils.dataSource(portletInstance.instanceData.dataSourceId);
            if (dataSourceData != null) {
                trace("preload: " + dataSourceData.databaseName, dataSourceData.tableName);
                PortletDataUtils.fetchTableData(dataSourceData.databaseName, dataSourceData.tableName).then(function(r) {
                    trace("preloaded: " + r.records.length);
                    resolve(true);
                });
            } else {
                resolve(true);
            }
        });
    }
}