package core.data;

import js.lib.Promise;
import core.data.dao.IDataTable;

@:build(core.data.dao.Macros.buildDataTable(IconData))
class IconDataTable implements IDataTable<IconData> {
    public function addDefaultData():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            var icons = [
                createObject([1, "database", "database-solid.png"]),
                createObject([2, "directions", "directions-solid.png"]),
                createObject([3, "dot", "dot.png"]),
                createObject([4, "exclamation", "exclamation-solid.png"]),
                createObject([5, "exclamation (triangle)", "exclamation-triangle-solid.png"]),
                createObject([6, "map marker", "map-marker-alt-solid.png"]),
                createObject([7, "search", "search-solid.png"]),
                createObject([8, "tachometer", "tachometer-alt-solid.png"])
            ];

            addObjects(icons).then(function(r) {
                resolve(true);
            });
        });
    }
}