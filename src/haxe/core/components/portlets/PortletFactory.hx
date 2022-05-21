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
            case "core.components.portlets.NestedPortletInstance":              instance = new NestedPortletInstance();
            case "core.components.portlets.BarGraphPortletInstance":            instance = new BarGraphPortletInstance();
            case "core.components.portlets.HorizontalBarGraphPortletInstance":  instance = new HorizontalBarGraphPortletInstance();
            case "core.components.portlets.LineGraphPortletInstance":           instance = new LineGraphPortletInstance();
            case "core.components.portlets.SiteMapPortletInstance":             instance = new SiteMapPortletInstance();
            case "core.components.portlets.StaticImagePortletInstance":         instance = new StaticImagePortletInstance();
            case "core.components.portlets.QuickFilterPortletInstance":         instance = new QuickFilterPortletInstance();
        }

        if (instance == null) {
            trace("WARNING: could not create portlet instance class: " + type);
        }

        return instance;
    }
}