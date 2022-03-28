package sidebars;

import views.OrganizationsView;
import core.data.InternalDB;
import haxe.ui.data.ArrayDataSource;
import core.data.ResourceType;
import haxe.ui.events.UIEvent;
import core.data.RoleData;

@:build(haxe.ui.ComponentBuilder.build("assets/sidebars/create-permission.xml"))
class CreatePermissionSidebar extends DataObjectSidebar {
    public var role:RoleData;

    public function new() {
        super();
    }

    public override function onReady() {
        super.onReady();
        title.text = "New Permission - " + role.name;
        return value;
    }

    @:bind(resourceTypeSelector, UIEvent.CHANGE)
    private function onResourceTypeSelectorChange(_) {
        var resourceType:Int = Std.parseInt(resourceTypeSelector.selectedItem.resourceType);
        var text:String = resourceTypeSelector.selectedItem.text;

        var ds = new ArrayDataSource<Dynamic>();
        ds.add({
            text: "Any " + text,
            resourceId: -1
        });

        switch (resourceType) {
            case ResourceType.Organization:
                for (org in InternalDB.organizations.data) {
                    ds.add({
                        text: org.name,
                        resourceId: org.organizationId
                    });
                }
            case ResourceType.User:
                for (user in InternalDB.users.data) {
                    ds.add({
                        text: user.username,
                        resourceId: user.userId
                    });
                }
            case ResourceType.UserGroup:
                for (userGroup in InternalDB.userGroups.data) {
                    ds.add({
                        text: userGroup.name,
                        resourceId: userGroup.userGroupId
                    });
                }
            case ResourceType.Role:
                for (role in InternalDB.roles.data) {
                    ds.add({
                        text: role.name,
                        resourceId: role.roleId
                    });
                }
            case ResourceType.Site:
            case ResourceType.Dashboard:
                for (dashboard in InternalDB.dashboards.data) {
                    ds.add({
                        text: dashboard.name,
                        resourceId: dashboard.dashboardId
                    });
                }
            case ResourceType.DashboardGroup:
                for (dashboardGroup in InternalDB.dashboardGroups.data) {
                    ds.add({
                        text: dashboardGroup.name,
                        resourceId: dashboardGroup.dashboardGroupId
                    });
                }
        }
        resourceSelector.selectedIndex = -1;
        resourceSelector.selectedIndex = 0;
        resourceSelector.dataSource = ds;
    }

    private override function createObject() {
        var permission = InternalDB.permissions.createObject();
        permission.roleId = role.roleId;
        permission.resourceId = resourceSelector.selectedItem.resourceId;
        permission.resourceType = Std.parseInt(resourceTypeSelector.selectedItem.resourceType);
        permission.permissionAction = Std.parseInt(actionSelector.selectedItem.actionType);

        InternalDB.permissions.addObject(permission).then(function(r) {
            createComplete();
            OrganizationsView.instance.populateOrgs();
        });
    }
}