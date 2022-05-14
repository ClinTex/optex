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

    public function availableLayoutsForPage(pageId:Int):Array<LayoutData> {
        var list = [];

        var page = InternalDB.pages.utils.page(pageId);
        if (page == null) {
            return list;
        }

        var site = InternalDB.sites.utils.site(page.siteId);
        if (site == null) {
            return list;
        }

        for (l in InternalDB.layouts.data) {
            if (l.organizationId == site.organizationId) {
                list.push(l);
            }
        }


        return list;
    }
}