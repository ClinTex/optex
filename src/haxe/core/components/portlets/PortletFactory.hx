package core.components.portlets;

class PortletFactory {
    private static var _instance:PortletFactory = null;
    public static var instance(get, null):PortletFactory;
    private static function get_instance():PortletFactory {
        if (_instance == null) {
            _instance = new PortletFactory();
        }
        return _instance;
    }

    //////////////////////////////////////////////////////////////////////////////////////////

    public function new() {
    }

    public function createInstance(type:String):PortletInstance {
        var instance:PortletInstance = null;
        switch (type) {
            case "nested-portlet":      instance = new NestedPortletInstance();
            case "bar-graph":           instance = new BarGraphPortletInstance();
            case "line-graph":          instance = new LineGraphPortletInstance();
            case "site-map":            instance = new SiteMapPortletInstance();
            case "static-image":        instance = new StaticImagePortletInstance();
            case "quick-filter":        instance = new QuickFilterPortletInstance();
        }
        return instance;
    }
}