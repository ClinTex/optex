package core.data;

class IconUtils {
    public function new() {
    }

    public function icon(iconId:Int):IconData {
        var icon = null;
        for (i in InternalDB.icons.data) {
            if (i.iconId == iconId) {
                icon = i;
                break;
            }
        }
        return icon;
    }
}