package core.data.utils;

import core.data.internal.CoreData.FieldType;

class ConversionUtils {
    public static inline function toString(value:Any):String {
        return Std.string(value);
    }
    
    public static function fromString(value:String, type:Int):Any {
        return switch (type) {
            case FieldType.String:
                value;
            case FieldType.Boolean:
                value == "true";
            case FieldType.Number:
                Std.parseFloat(value);
            case _:
                value;
        }
    }
}