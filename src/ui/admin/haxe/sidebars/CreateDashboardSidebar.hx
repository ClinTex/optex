package sidebars;

import views.DashboardsView;
import haxe.ui.ToolkitAssets;
import components.WorkingIndicator;
import haxe.ui.events.MouseEvent;
import haxe.ui.containers.SideBar;
import core.data.IconData;
import core.data.DashboardGroupData;
import core.data.DashboardData;
import haxe.ui.data.ArrayDataSource;
import core.data.DatabaseManager;
import haxe.ui.events.UIEvent;

@:build(haxe.ui.ComponentBuilder.build("assets/sidebars/create-dashboard.xml"))
class CreateDashboardSidebar extends SideBar {
    private var _nextDashboardId:Int = -1;
    private var _nextDashboardGroupId:Int = -1;

    public function new() {
        super();
    }

    @:bind(createNewGroupOption, UIEvent.CHANGE)
    @:bind(addToExistingGroupOption, UIEvent.CHANGE)
    private function onCreateCoreChanged(e:UIEvent) {
        if (createNewGroupOption.selected == true) {
            newGroupName.disabled = false;
            newGroupIcon.disabled = false;
            existingGroupSelector.disabled = true;
        } else if (addToExistingGroupOption.selected == true) {
            newGroupName.disabled = true;
            newGroupIcon.disabled = true;
            existingGroupSelector.disabled = false;
        }
    }

    public var iconData(null, set):Array<IconData>;
    private function set_iconData(value:Array<IconData>) {
        var ds = new ArrayDataSource<Dynamic>();
        for (icon in value) {
            ds.add({
                text: icon.name,
                icon: "themes/optex/" + icon.path,
                iconData: icon
            });
        }

        newGroupIcon.dataSource = ds;
        dashboardIconField.dataSource = ds;
        return value;
    }

    public var dashboardData(null, set):Array<DashboardData>;
    private function set_dashboardData(value:Array<DashboardData>) {
        for (dashboard in value) {
            if (dashboard.dashboardId > _nextDashboardId) {
                _nextDashboardId = dashboard.dashboardId;
            }
        }
        _nextDashboardId++;
        return value;
    }

    public var groupData(null, set):Array<DashboardGroupData>;
    private function set_groupData(value:Array<DashboardGroupData>) {
        var ds = new ArrayDataSource<Dynamic>();
        for (group in value) {
            ds.add({
                text: group.name,
                groupData: group
            });

            if (group.dashboardGroupId > _nextDashboardGroupId) {
                _nextDashboardGroupId = group.dashboardGroupId;
            }
        }
        _nextDashboardGroupId++;
        existingGroupSelector.dataSource = ds;
        if (value.length > 0) {
            addToExistingGroupOption.show();
            existingGroupSelector.show();
        }
        return value;
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

        var dashboard:DashboardData = DatabaseManager.instance.internal.dashboardData.createObject();
        if (createNewGroupOption.selected == true) {
            var groupName = newGroupName.text;
            var iconData:IconData = newGroupIcon.selectedItem.iconData;

            var group = DatabaseManager.instance.internal.dashboardGroupData.createObject();
            group.dashboardGroupId = _nextDashboardGroupId;
            group.name = groupName;
            group.order = 0;
            group.iconId = iconData.iconId;
            dashboard.group = group;
            dashboard.dashboardGroupId = group.dashboardGroupId;
        } else if (addToExistingGroupOption.selected == true) {
            var group:DashboardGroupData = existingGroupSelector.selectedItem.groupData;
            dashboard.dashboardGroupId = group.dashboardGroupId;
        }

        var iconData:IconData = dashboardIconField.selectedItem.iconData;

        dashboard.dashboardId = _nextDashboardId;
        dashboard.name = dashboardNameField.text;
        dashboard.order = 0;

        var dashboardTemplate = dashboardTemplateField.selectedItem.file;
        var dashboardLayoutData = ToolkitAssets.instance.getText(dashboardTemplate);
        dashboard.layoutData = dashboardLayoutData;
        dashboard.iconId = iconData.iconId;

        _working = new WorkingIndicator();
        _working.showWorking();
        dashboard.add().then(function(r) {
            _working.workComplete();
            DashboardsView.instance.refreshDashboardSelector(dashboard.dashboardId);
        });
    }

    private override function onHideAnimationEnd() {
        super.onHideAnimationEnd();
        createDashboard();
    }
}