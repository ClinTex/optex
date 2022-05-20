package core.util.color;

interface IColorCalculator {
    function configure(params:Array<Any>):Void;
    function getColor(data:Dynamic, index:Int = 0, graphInfo:Dynamic = null):String;
}