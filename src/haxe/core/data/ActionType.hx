package core.data;

class ActionType {
    public static inline var View:Int   = 1;
    public static inline var Update:Int = 2;
    public static inline var Add:Int    = 3;
    public static inline var Delete:Int = 4;

    public static function toString(actionType:Int):String {
        return switch(actionType) {
            case View: "View";
            case Update: "Update";
            case Add: "Add";
            case Delete: "Delete";
            case _: "Unknown";
        }
    }
}