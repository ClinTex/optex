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
            return Math.abs(data[index1].y - data[index2].y);
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