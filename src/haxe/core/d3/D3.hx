package core.d3;

import js.Syntax;

@:native("d3")
extern class D3 {
    public static function select(el:Dynamic):Dynamic;
    public static function selectAll(el:Dynamic):Dynamic;
    public static function scaleOrdinal():Dynamic;
    public static function scaleBand():Dynamic;
    public static function scaleLinear():Dynamic;
    public static function pie():Dynamic;
    public static function set():Dynamic;
    public static function arc():Dynamic;
    public static function entries(data:Dynamic):Dynamic;
    public static function merge(data:Dynamic):Dynamic;
    public static function ascending(a:Dynamic, b:Dynamic):Dynamic;
    public static function interpolate(a:Dynamic, b:Dynamic):Dynamic;
    public static function axisBottom(x:Dynamic):Dynamic;
    public static function axisLeft(x:Dynamic):Dynamic;
    
    public static inline function field(o:Dynamic, name:String):Dynamic {
        return Syntax.code("{0}[{1}]", o, name);
    }
}