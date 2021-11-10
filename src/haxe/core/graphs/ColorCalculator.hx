package core.graphs;

import core.d3.D3;
import haxe.ui.util.StringUtil;

class ColorCalculator {
    private var _colors:Array<String> = null;
    private var _colorsReverse:Array<String> = null;
    
    public function new() {
    }
    
    private var _scheme:String;
    public var scheme(get, set):String;
    private function get_scheme():String {
        return _scheme;
    }
    private function set_scheme(value:String):String {
        _scheme = value;
        var schemaName = "scheme" + StringUtil.capitalizeFirstLetter(_scheme);
        var colors:Array<Dynamic> = D3.field(D3, schemaName);
        _colors = colors.copy().pop();
        _colorsReverse = _colors.copy();
        _colorsReverse.reverse();
        return value;
    }
    
    public function get(data:Dynamic, index:Int, graphInfo:Dynamic):String {
        return null;
    }
}

class ValueBasedColourCalculator extends ColorCalculator {
    public override function get(data:Dynamic, index:Int, graphInfo:Dynamic):String {
        var max = graphInfo.valueMax;
        var value = Reflect.field(data, graphInfo.valueField);
        var colMax = _colors.length;
        var colIndex = Math.round((value / max) * colMax) - 1;
        if (colIndex < 0) {
            colIndex = 0;
        }
        return _colorsReverse[colIndex];
    }
}

class ThresholdBasedColourCalculator extends ColorCalculator {
    private var threshold:Float = 50;
    
    public function new(threshold:Float) {
        super();
        this.threshold = threshold;
    }
    
    public override function get(data:Dynamic, index:Int, graphInfo:Dynamic):String {
        var v = D3.field(data, graphInfo.yAxisField);
        if (v < threshold) {
            return "#880000";
        }
        return "#008800";
    }
}