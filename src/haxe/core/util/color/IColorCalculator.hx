package core.util.color;

interface IColorCalculator {
    function configure(params:Array<Any>):Void;
    function getColor(data:Dynamic):String;
}