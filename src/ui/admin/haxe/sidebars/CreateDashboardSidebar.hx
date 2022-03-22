package sidebars;

import core.data.utils.PromiseUtils;
import js.lib.Promise;
import core.data.InternalDB;
import views.DashboardsView;
import haxe.ui.ToolkitAssets;
import core.data.IconData;
import core.data.DashboardGroupData;
import haxe.ui.events.UIEvent;

@:build(haxe.ui.ComponentBuilder.build("assets/sidebars/create-dashboard.xml"))
class CreateDashboardSidebar extends DataObjectSidebar {
    public function new() {
        super();
    }

    public override function onReady() {
        super.onReady();
        if (InternalDB.dashboardGroups.data.length > 0) {
            addToExistingGroupOption.show();
            existingGroupSelector.show();
        }
        return value;
    }

    @:bind(createNewGroupOption, UIEvent.CHANGE)
    @:bind(addToExistingGroupOption, UIEvent.CHANGE)
    private function onCreateOrExistingChanged(e:UIEvent) {
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

    private override function createObject() {
        var dashboard = InternalDB.dashboards.createObject();
        var promises:Array<Promise<Bool>> = [];
        if (createNewGroupOption.selected == true) {
            var iconData:IconData = newGroupIcon.selectedItem.iconData;

            var group = InternalDB.dashboardGroups.createObject();
            group.name = newGroupName.text;
            group.order = 0;
            group.iconId = iconData.iconId;
            dashboard.group = group;
            dashboard.dashboardGroupId = group.dashboardGroupId;
            promises.push(InternalDB.dashboardGroups.addObject(group));
        } else if (addToExistingGroupOption.selected == true) {
            var group:DashboardGroupData = existingGroupSelector.selectedItem.groupData;
            dashboard.dashboardGroupId = group.dashboardGroupId;
        }

        var iconData:IconData = dashboardIconField.selectedItem.iconData;
        dashboard.name = dashboardNameField.text;
        dashboard.order = 0;

        var dashboardTemplate = dashboardTemplateField.selectedItem.file;
        var dashboardLayoutData = ToolkitAssets.instance.getText(dashboardTemplate);
        dashboard.layoutData = dashboardLayoutData;
        dashboard.iconId = iconData.iconId;

        promises.push(InternalDB.dashboards.addObject(dashboard));
        PromiseUtils.runSequentially(promises, function() {
            createComplete();
            DashboardsView.instance.refreshDashboardSelector(dashboard.dashboardId);
        });
    }
}