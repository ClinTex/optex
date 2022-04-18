package core.data;

class LayoutUtils {
    public function new() {
    }

    public function layout(layoutId:Int):LayoutData {
        var layout = null;
        for (l in InternalDB.layouts.data) {
            if (l.layoutId == layoutId) {
                layout = l;
                break;
            }
        }
        return layout;
    }
}