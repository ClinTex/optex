package core.graphs;

import core.util.FunctionDetails;

class MarkerFunctions {
    public static function get(s:String):Dynamic->Int->Float {
        if (s == null) {
            return null;
        }

        var details = new FunctionDetails(s);

        var fn:MarkerFunction = null;

        switch (details.name) {
            case "deltay":
                fn = new DeltaDataY();
            case "staticy":
                fn = new StaticY();
        }

        if (fn == null) {
            return null;
        }

        fn.params = details.params;
        return fn.get();
    }
}

class MarkerFunction {
    public var params:Array<Any> = [];

    public function new() {
    }

    public function get():Dynamic->Int->Float {
        return null;
    }
}

class DeltaDataY extends MarkerFunction {
    public override function get():Dynamic->Int->Float {
        var index1:Int = params[0];
        var index2:Int = params[1];
        return function(data:Dynamic, index:Int) {
            var d1 = 0;
            if (data != null && data[index1] != null) {
                d1 = data[index1].y;
            }
            var d2 = 0;
            if (data != null && data[index2] != null) {
                d2 = data[index2].y;
            }
            return Math.abs(d1 - d2);
        };
    }
}

class StaticY extends MarkerFunction {
    public override function get():Dynamic->Int->Float {
        var value:Int = params[0];
        return function(data:Dynamic, index:Int) {
            return value;
        };
    }
}