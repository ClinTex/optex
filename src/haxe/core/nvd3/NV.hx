package core.nvd3;

@:native("nv")
extern class NV {
    public static function addGraph(callback:Void->Dynamic):Void;
    public static var models:Dynamic;
}