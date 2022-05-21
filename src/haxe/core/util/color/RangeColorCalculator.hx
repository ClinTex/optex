package core.util.color;

import core.d3.D3;

typedef RangeColorCalculatorRange = {
    var type:String;
    var value1:Null<Float>;
    var value2:Null<Float>;
    var color:String;
}

class RangeColorCalculator extends ColorCalculator {
    private var _ranges:Array<RangeColorCalculatorRange>;

    public override function configure(params:Array<Any>) {
        _ranges = [];

        var n = Std.int(params.length / 2);
        for (i in 0...n) {
            var condition = Std.string(params[i * 2 + 0]);
            var parts = condition.split(" ");
            var type = parts.shift();
            var value1:Null<Float> = null;
            var value2:Null<Float> = null;
            switch (type) {
                case "lt":
                    value1 = Std.parseFloat(parts.shift());
                case "btwn":
                    value1 = Std.parseFloat(parts.shift());
                    value2 = Std.parseFloat(parts.shift());
                case "gt":
                    value1 = Std.parseFloat(parts.shift());
            }

            var color = "#" + StringTools.hex(Std.parseInt(Std.string(params[i * 2 + 1])), 6);
            _ranges.push({
                type: type,
                value1: value1,
                value2: value2,
                color: color
            });
        }
    }

    public override function getColor(data:Dynamic, index:Int = 0, graphInfo:Dynamic = null):String {
        var v = D3.field(data, graphInfo.yAxisField);
        for (range in _ranges) {
            switch (range.type) {
                case "lt":
                    if (v < range.value1) {
                        return range.color;
                    }
                case "btwn":
                    if (v >= range.value1 && v <= range.value2) {
                        return range.color;
                    }
                case "gt":
                    if (v > range.value1) {
                        return range.color;
                    }
            }
        }
        return null;
    }
}