package views;

import core.data.InternalDB;
import core.data.IconData;
import core.data.DashboardData;
import core.data.DashboardGroupData;
import haxe.ui.Toolkit;
import haxe.ui.components.Button;
import haxe.ui.events.UIEvent;
import sidebars.CreateDashboardSidebar;
import haxe.ui.events.MouseEvent;
import haxe.ui.containers.VBox;
import components.WorkingIndicator;

@:build(haxe.ui.ComponentBuilder.build("assets/views/dashboards.xml"))
class DashboardsView extends VBox {
    public static var instance:DashboardsView;

    public function new() {
        super();
        instance = this;
        dashboardDetails.hide();
        refreshDashboardSelector();
    }

    public function refreshDashboardSelector(groupId:Null<Int> = null, dashboardId:Null<Int> = null) {
        var map = InternalDB.dashboards.utils.byGroup;
        dashboardTree.clearNodes();
        var firstNode = null;
        var nodeToSelect = null;
        for (group in map.keys()) {
            var groupNode = dashboardTree.addNode({text: group.name, icon: "themes/optex/" + group.icon.path, groupData: group});
            if (firstNode == null) {
                firstNode = groupNode;
            }
            if (groupId !=  null && group.dashboardGroupId == groupId) {
                nodeToSelect = groupNode;
            }
            groupNode.expanded = true;
            var dashboards = map.get(group);
            for (dashboard in dashboards) {
                var dashboardNode = groupNode.addNode({text: dashboard.name, icon: "themes/optex/" + dashboard.icon.path, dashboardData: dashboard});
                if (dashboardId != null && dashboard.dashboardId == dashboardId) {
                    nodeToSelect = dashboardNode;
                }
            }
        }

        if (nodeToSelect == null) {
            nodeToSelect = firstNode;
        }

        if (nodeToSelect != null) {
            Toolkit.callLater(function() {
                dashboardTree.selectedNode = nodeToSelect;
            });
        }
    }

    @:bind(addDashboardButton, MouseEvent.CLICK)
    private function onAddDataButton(e:MouseEvent) {
        var sidebar = new CreateDashboardSidebar();
        sidebar.position = "right";
        sidebar.modal = true;
        sidebar.show();
    }

    @:bind(updateDetailsButton, MouseEvent.CLICK)
    private function onUpdateDetailsButton(e:MouseEvent) {
        var selectedItem = dashboardTree.selectedNode;
        if (selectedItem == null) {
            return;
        }
        if (selectedItem.data.groupData != null) {
            var groupData:DashboardGroupData = selectedItem.data.groupData;
            var iconData:IconData = dashboardGroupIconField.selectedItem.iconData;

            groupData.name = dashboardGroupNameField.text;
            groupData.iconId = iconData.iconId;

            var working = new WorkingIndicator();
            working.showWorking();
            InternalDB.dashboardGroups.updateObject(groupData).then(function(r) {
                InternalDB.dashboards.fillCache().then(function(r) { // TODO: would be nice for this to be automatic
                    working.workComplete();
                    refreshDashboardSelector(groupData.dashboardGroupId, null);
                });
            });
        } else if (selectedItem.data.dashboardData != null) {
            var dashboardData:DashboardData = selectedItem.data.dashboardData;
            var iconData:IconData = dashboardIconField.selectedItem.iconData;

            dashboardData.name = dashboardNameField.text;
            dashboardData.layoutData = dashboardDataField.text;
            dashboardData.iconId = iconData.iconId;

            var working = new WorkingIndicator();
            working.showWorking();
            InternalDB.dashboards.updateObject(dashboardData).then(function(r) {
                working.workComplete();
                refreshDashboardSelector(null, dashboardData.dashboardId);
            });
        }
    }

    private var _firstLoad:Bool = true;
    @:bind(dashboardTree, UIEvent.CHANGE)
    private function onDashboardTreeSelectionChange(e:UIEvent) {
        var selectedItem = dashboardTree.selectedNode;
        if (selectedItem == null || selectedItem.data == null) {
            return;
        }

        if (selectedItem.data.groupData != null) {
            var groupData:DashboardGroupData = selectedItem.data.groupData;

            dashboardGroupNameLabel.text = groupData.name + " Details";
            dashboardGroupIdField.text = "" + groupData.dashboardGroupId;
            dashboardGroupNameField.text = groupData.name;
            dashboardGroupIconField.selectedItem = groupData.icon.name;

            dashboardGroupDetails.show();
            dashboardDetails.hide();            
        } else if (selectedItem.data.dashboardData != null) {
            var dashboardData:DashboardData = selectedItem.data.dashboardData;

            dashboardNameLabel.text = dashboardData.name + " Details";
            dashboardIdField.text = "" + dashboardData.dashboardId;
            dashboardNameField.text = dashboardData.name;
            dashboardIconField.selectedItem = dashboardData.icon.name;
            dashboardGroupField.selectedItem = dashboardData.group.name;
            dashboardDataField.text = dashboardData.layoutData;

            dashboardGroupDetails.hide();
            dashboardDetails.show();            
        }
    }

    @:bind(dashboardDetailsTabs, UIEvent.CHANGE)
    private function onDashboardDetailsTabsChange(e:UIEvent) {
        var selectedItem = dashboardTree.selectedNode;
        if (selectedItem == null || selectedItem.data == null) {
            return;
        }

        if (selectedItem.data.dashboardData != null) {
            var dashboardData:DashboardData = selectedItem.data.dashboardData;
            dashboardPreviewInstance.buildDashboard(dashboardData);
        } else {
            dashboardPreviewInstance.clearDashboard();
        }
    }
}