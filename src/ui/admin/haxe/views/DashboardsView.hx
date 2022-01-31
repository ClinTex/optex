package views;

import core.data.IconData;
import core.data.DashboardData;
import core.data.DashboardGroupData;
import haxe.ui.util.Timer;
import haxe.ui.Toolkit;
import haxe.ui.ToolkitAssets;
import haxe.ui.ToolkitAssets;
import haxe.ui.components.Button;
import haxe.ui.events.UIEvent;
import haxe.ui.data.ArrayDataSource;
import sidebars.CreateDashboardSidebar;
import haxe.ui.events.MouseEvent;
import haxe.ui.containers.VBox;
import core.data.DatabaseManager;
import components.WorkingIndicator;

@:build(haxe.ui.ComponentBuilder.build("assets/views/dashboards.xml"))
class DashboardsView extends VBox {
    public static var instance:DashboardsView;

    //private var _dashboardsTable:Table;

    public function new() {
        super();
        instance = this;
        dashboardDetails.hide();
        DatabaseManager.instance.listen(DatabaseEvent.Initialized, function(_) {
            populateIcons();
        });
    }

    private function populateIcons() {
        DatabaseManager.instance.internal.iconData.fetch().then(function(icons) {
            var ds = new ArrayDataSource<Dynamic>();
            for (icon in icons) {
                ds.add({
                    text: icon.name,
                    icon: "themes/optex/" + icon.path,
                    iconData: icon
                });
            }
    
            dashboardGroupIconField.dataSource = ds;
            dashboardIconField.dataSource = ds;
            populateGroups();
        });
    }

    private function populateGroups() {
        DatabaseManager.instance.internal.dashboardGroupData.fetch().then(function(groups) {
            var ds = new ArrayDataSource<Dynamic>();
            for (group in groups) {
                ds.add({
                    text: group.name,
                    groupData: group
                });
            }

            dashboardGroupField.dataSource = ds;
            refreshDashboardSelector();
        });
    }

    public function refreshDashboardSelector(groupId:Null<Int> = null, dashboardId:Null<Int> = null) {
        DatabaseManager.instance.internal.dashboardData.getDashboardsByGroup().then(function(map) {
            dashboardTree.clearNodes();
            var firstNode = null;
            var nodeToSelect = null;
            for (group in map.keys()) {
                var groupNode = dashboardTree.addNode({text: group.name, icon: "themes/optex/" + group.icon.path, groupData: group});
                if (firstNode == null) {
                    firstNode = groupNode;
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
        });
    }

    @:bind(addDashboardButton, MouseEvent.CLICK)
    private function onAddDataButton(e:MouseEvent) {
        var working = new WorkingIndicator();
        working.showWorking();
        DatabaseManager.instance.internal.iconData.fetch().then(function(icons) {
            DatabaseManager.instance.internal.dashboardGroupData.fetch().then(function(groups) {
                DatabaseManager.instance.internal.dashboardData.fetch().then(function(dashboards) {
                    working.workComplete();
                    var sidebar = new CreateDashboardSidebar();
                    sidebar.iconData = icons;
                    sidebar.groupData = groups;
                    sidebar.dashboardData = dashboards;
                    sidebar.position = "right";
                    sidebar.modal = true;
                    sidebar.show();
                });
            });
        });
    }

    @:bind(updateDetailsButton, MouseEvent.CLICK)
    private function onUpdateDetailsButton(e:MouseEvent) {
        var selectedItem = dashboardTree.selectedNode;
        if (selectedItem == null) {
            return;
        }
        if (selectedItem.data.groupData != null) {
            var groupData:DashboardGroupData = selectedItem.data.groupData;
        } else if (selectedItem.data.dashboardData != null) {
            var dashboardData:DashboardData = selectedItem.data.dashboardData;
            var iconData:IconData = dashboardIconField.selectedItem.iconData;

            dashboardData.name = dashboardNameField.text;
            dashboardData.layoutData = dashboardDataField.text;
            dashboardData.iconId = iconData.iconId;

            var working = new WorkingIndicator();
            working.showWorking();
            dashboardData.update().then(function(r) {
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