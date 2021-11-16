package sidebars;

import views.DashboardsView;
import haxe.ui.ToolkitAssets;
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
        var dashboardIcon = dashboardIconField.text;
        var dashboardTemplate = dashboardTemplateField.selectedItem.file;
        var layoutData = ToolkitAssets.instance.getText(dashboardTemplate);

        var dashboard = new Dashboard(dashboardName);
        dashboard.icon = dashboardIcon;
        dashboard.layoutData = layoutData;

        _working = new WorkingIndicator();
        _working.showWorking();
        DashboardManager.instance.createDashboard(dashboard).then(function (r) {
            _working.workComplete();
            DashboardsView.instance.refreshDashboardSelector(dashboardName);
        });
    }

    private override function onHideAnimationEnd() {
        super.onHideAnimationEnd();
        createDashboard();
    }
}