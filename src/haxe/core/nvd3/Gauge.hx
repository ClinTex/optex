package core.nvd3;

@:native("Gauge")
extern class Gauge {
    public var maxValue:Float;
    public var animationSpeed:Float;
    
    public function new(el:Dynamic);
    public function setOptions(o:Dynamic):Dynamic;
    public function setMinValue(v:Float):Void;
    public function set(v:Float):Void;
    public function setTextField(v:Dynamic):Void;
    public function update(b:Bool):Void;
}
