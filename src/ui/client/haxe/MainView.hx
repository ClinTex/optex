package;

import core.data.DashboardData;
import haxe.ui.Toolkit;
import haxe.ui.containers.HorizontalSplitter;
import haxe.ui.containers.VerticalSplitter;
import haxe.ui.components.Spacer;
import haxe.ui.components.Label;
import haxe.ui.components.Link;
import haxe.ui.components.Image;
import haxe.ui.containers.Box;
import core.dashboards.Portlet;
import haxe.ui.containers.HBox;
import haxe.ui.containers.Card;
import haxe.ui.core.ComponentClassMap;
import haxe.ui.events.UIEvent;
import core.data.DatabaseManager;
import haxe.ui.containers.VBox;

@:build(haxe.ui.ComponentBuilder.build("assets/main-view.xml"))
class MainView extends VBox {
    public function new() {
        super();

        ComponentClassMap.instance.registerClassName("vbox", Type.getClassName(VBox));
        ComponentClassMap.instance.registerClassName("hbox", Type.getClassName(HBox));
        ComponentClassMap.instance.registerClassName("box", Type.getClassName(Box));
        ComponentClassMap.instance.registerClassName("portlet", Type.getClassName(Portlet));
        ComponentClassMap.instance.registerClassName("card", Type.getClassName(Card));
        ComponentClassMap.instance.registerClassName("image", Type.getClassName(Image));
        ComponentClassMap.instance.registerClassName("link", Type.getClassName(Link));
        ComponentClassMap.instance.registerClassName("label", Type.getClassName(Label));
        ComponentClassMap.instance.registerClassName("spacer", Type.getClassName(Spacer));
        ComponentClassMap.instance.registerClassName("vertical-splitter", Type.getClassName(VerticalSplitter));
        ComponentClassMap.instance.registerClassName("horizontal-splitter", Type.getClassName(HorizontalSplitter));
        ComponentClassMap.instance.registerClassName("vsplitter", Type.getClassName(VerticalSplitter));
        ComponentClassMap.instance.registerClassName("hsplitter", Type.getClassName(HorizontalSplitter));

        DatabaseManager.instance.init().then(function(r) {
            trace("database manager ready");
        });
        
        DatabaseManager.instance.listen(DatabaseEvent.Initialized, function(_) {
            refreshDashboardSelector();
        });
    }

    public function refreshDashboardSelector() {
        var dashboardId:Null<Int> = null;
        DatabaseManager.instance.internal.dashboardData.getDashboardsByGroup().then(function(map) {
            dashboardTree.clearNodes();
            var firstNode = null;
            var nodeToSelect = null;
            var nGroup = 0;
            for (group in map.keys()) {
                var groupNode = dashboardTree.addNode({text: group.name, icon: "themes/optex/" + group.icon.path, groupData: group});
                if (nGroup == 0) {
                    groupNode.expanded = true;
                }

                var dashboards = map.get(group);
                for (dashboard in dashboards) {
                    var dashboardNode = groupNode.addNode({text: dashboard.name, icon: "themes/optex/" + dashboard.icon.path, dashboardData: dashboard});
                    if (firstNode == null) {
                        firstNode = dashboardNode;
                    }
                    if (dashboardId != null && dashboard.dashboardId == dashboardId) {
                        nodeToSelect = dashboardNode;
                    }
                }
                nGroup++;
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

    @:bind(dashboardTree, UIEvent.CHANGE)
    private function onDashboardTreeChange(_) {
        var selectedItem = dashboardTree.selectedNode;
        if (selectedItem == null || selectedItem.data == null) {
            return;
        }

        if (selectedItem.data.dashboardData != null) {
            var dashboardData:DashboardData = selectedItem.data.dashboardData;
            dashboardInstance.buildDashboard(dashboardData);
        } else {
            //selectedItem.expanded = !selectedItem.expanded;
        }
    }
}