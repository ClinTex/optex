package core.data;

import js.lib.Promise;
import core.Types.TDataSource;
import core.Types.TFieldDefinition;

class DataSourceManager {
    private static var _instance:DataSourceManager = null;
    public static var instance(get, null):DataSourceManager;
    private static function get_instance():DataSourceManager {
        if (_instance == null) {
            _instance = new DataSourceManager();
        }
        return _instance;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // INSTANCE
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    private var _cachedDataSources:Array<DataSource> = null;

    private function new() {
    }

    public var dataSources(get, null):Array<DataSource>;
    private function get_dataSources():Array<DataSource> {
        if (_cachedDataSources == null) {
            throw "refreshDataSources must be called at least once";
        }
        return _cachedDataSources;
    }

    public function refreshDataSources():Promise<Array<DataSource>> {
        return new Promise((resolve, reject) -> {
            CoreData.listDataSources().then(function(result:Array<TDataSource>) {
                var dataSources:Array<DataSource> = [];
                for (r in result) {
                    var ds = new DataSource(r);
                    dataSources.push(ds);
                }
                _cachedDataSources = dataSources;
                resolve(dataSources);
            });
        });
    }

    public function updateDataSource(ds:DataSource):Promise<Dynamic> {
        return new Promise((resolve, reject) -> {
            // TODO: should be update, not create
            CoreData.createDataSource(ds.raw).then(function(result) {
                resolve(result);
            });
        });
    }
}