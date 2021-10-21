package core.data;

import js.lib.Promise;
import core.Types.TDataSource;

@:native("core_data")
extern class CoreData {
    static function listDataSourceNames():Promise<Array<String>>;
    static function createDataSource(dataSource:TDataSource):Promise<Any>;
    static function listDataSources():Promise<Array<TDataSource>>;
}
