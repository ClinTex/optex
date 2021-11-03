package sidebars;

import core.data.DashboardManager;
import core.data.Dashboard;
import components.WorkingIndicator;
import haxe.ui.events.MouseEvent;
import haxe.ui.containers.SideBar;

@:build(haxe.ui.ComponentBuilder.build("assets/sidebars/create-dashboard.xml"))
class CreateDashboardSidebar extends SideBar {
    public function new() {
        super();
    }

    private var _create:Bool = false;
    @:bind(cancelButton, MouseEvent.CLICK)
    private function onCancel(e:MouseEvent) {
        _create = false;
        hide();
    }

    private var _working:WorkingIndicator;
    @:bind(createButton, MouseEvent.CLICK)
    private function onCreate(e:MouseEvent) {
        _create = true;
        hide();
    }

    private function createDashboard() {
        if (_create == false) {
            return;
        }

        var dashboardName = dashboardNameField.text;
        var dashboard = new Dashboard(dashboardName);

        var layoutData = "";
        layoutData += "<vbox width='100%'>\n";
        layoutData += "    <hbox width='100%'>\n";
        layoutData += "        <portlet id='portletA' type='chart-bar'>\n";
        layoutData += "            <data>\n";
        layoutData += "            </data>\n";
        layoutData += "        </portlet>\n";
        layoutData += "        <portlet id='portletB' type='chart-bar'>\n";
        layoutData += "            <data>\n";
        layoutData += "            </data>\n";
        layoutData += "        </portlet>\n";
        layoutData += "    </hbox>\n";
        layoutData += "</vbox>\n";
        dashboard.layoutData = layoutData;

        _working = new WorkingIndicator();
        _working.showWorking();
        DashboardManager.instance.createDashboard(dashboard).then(function (r) {
            _working.workComplete();
        });
    }

    private override function onHideAnimationEnd() {
        super.onHideAnimationEnd();
        createDashboard();
    }
}