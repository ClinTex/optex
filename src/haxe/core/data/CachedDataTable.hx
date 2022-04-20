package core.data;

import js.lib.Promise;
import core.data.dao.IDataTable;
import core.data.dao.IDataObject;

class CachedDataTable<T:IDataTable<O>, O:IDataObject, U> {
    public var utils:U;
    private var _table:T;
    public var data:Array<O> = null;

    public function new(table:T, utils:U = null) {
        this.utils = utils;
        _table = table;
    }

    public function fillCache():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            _table.fetch().then(function(results) {
                data = results;
                resolve(true);
            });
        });
    }

    public function createObject():O {
        var o = _table.createObject();
        o.primaryKey = nextPrimaryKey;
        return o;
    }

    public function addObject(o:O, refreshCache:Bool = true):Promise<Bool> {
        return new Promise((resolve, reject) -> {
            _table.addObject(o).then(function(r) {
                if (r == true && refreshCache == true) {
                    fillCache().then(function(r) {
                        resolve(r);
                    });
                } else {
                    resolve(r);
                }
            });
        });
    }

    public function updateObject(o:O, refreshCache:Bool = true):Promise<Bool> {
        return new Promise((resolve, reject) -> {
            _table.updateObject(o).then(function(r) {
                if (r == true && refreshCache == true) {
                    fillCache().then(function(r) {
                        resolve(r);
                    });
                } else {
                    resolve(r);
                }
            });
        });
    }

    public function removeObject(o:O, refreshCache:Bool = true):Promise<Bool> {
        return new Promise((resolve, reject) -> {
            _table.removeObject(o).then(function(r) {
                if (r == true && refreshCache == true) {
                    fillCache().then(function(r) {
                        resolve(r);
                    });
                } else {
                    resolve(r);
                }
            });
        });
    }

    public var nextPrimaryKey(get, null):Int;
    private function get_nextPrimaryKey():Int {
        var n = -1;
        for (d in data) {
            if (d.primaryKey > n) {
                n = d.primaryKey;
            }
        }
        n++;
        return n;
    }
}