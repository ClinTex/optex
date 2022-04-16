package core.data;

class ResourceType {
    public static inline var Organization:Int   = 1;
    public static inline var User:Int           = 2;
    public static inline var UserGroup:Int      = 3;
    public static inline var Role:Int           = 4;
    public static inline var Site:Int           = 5;
    public static inline var Dashboard:Int      = 6;
    public static inline var DashboardGroup:Int = 7;
    public static inline var DataSource:Int     = 8;

    public static function toString(actionType:Int):String {
        return switch(actionType) {
            case Organization: "Organization";
            case User: "User";
            case UserGroup: "User Group";
            case Role: "Role";
            case Site: "Site";
            case Dashboard: "Dashboard";
            case DashboardGroup: "Dashboard Group";
            case DataSource: "Data Source";
            case _: "Unknown";
        }
    }
}