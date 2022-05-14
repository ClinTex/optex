package core.data;

class SiteUtils {
    public function new() {
    }

    public function site(siteId:Int):SiteData {
        var site = null;
        for (s in InternalDB.sites.data) {
            if (s.siteId == siteId) {
                site = s;
                break;
            }
        }
        return site;
    }

}