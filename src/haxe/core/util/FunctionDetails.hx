package core.util;

import haxe.ui.util.TypeConverter;

using StringTools;

class FunctionDetails {
    private var _s:String;

    public var name:String;
    public var params:Array<Any>;

    public function new(s:String) {
        _s = s;
        parse(s);
    }

    private function parse(s:String) {
        s  = s.trim();
        params = [];
        var n1 = s.indexOf("(");
        if (n1 == -1) {
            name = s;
        } else {
            name = s.substring(0, n1);
            var rest = s.substring(n1 + 1, s.length - 1);
            var p = rest.split(",");
            for (i in p) {
                i = i.trim();
                if (i.length == 0) {
                    continue;
                }
                i = i.replace("'", "");
                i = i.replace("\"", "");
                params.push(TypeConverter.convertFrom(i));
            }
        }

        name = name.toLowerCase();
        name = name.replace("-", "");
        name = name.replace("_", "");
    }
}