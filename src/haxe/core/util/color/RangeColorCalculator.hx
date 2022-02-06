package core.util.color;

typedef RangeColorCalculatorRange = {
    var start:Float;
    var end:Float;
    var color:String;
}

class RangeColorCalculator extends ColorCalculator {
    private var _ranges:Array<RangeColorCalculatorRange>;

    public override function configure(params:Array<Any>) {
        _ranges = [];

        var n = Std.int(params.length / 3);
        for (i in 0...n) {
            _ranges.push({
                start: params[i * 3 + 0],
                end: params[i * 3 + 1],
                color: params[i * 3 + 2]
            });
        }
    }

    public override function getColor(data:Dynamic):String {
        var i:Float = data;
        for (range in _ranges) {
            if (i >= range.start && i <= range.end) {
                return range.color;
            }
        }
        return null;
    }
}