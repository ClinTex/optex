package core.data;

class DataSourceUtils {
    public function new() {
    }

    public function dataSource(dataSourceId:Int):DataSourceData {
        for (d in InternalDB.dataSources.data) {
            if (d.dataSourceId == dataSourceId) {
                return d;
            }
        }
        return null;
    }
}