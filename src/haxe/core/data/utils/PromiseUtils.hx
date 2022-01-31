package core.data.utils;

import js.lib.Promise;

class PromiseUtils {
    public static function runSequentially<T>(list:Array<Promise<T>>, cb:Void->Void, failed:Dynamic->Void = null) {
        if (list.length == 0) {
            cb();
            return;
        }

        var p = list.shift();
        p.then(function(r) {
            runSequentially(list, cb, failed);
        }).catchError(function(e) {
            if (failed != null) {
                failed(e);
            }
            return;
        });
    }

}