package dialogs;

import haxe.ui.events.UIEvent;
import core.data.InternalDB;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.containers.dialogs.Dialog;
import core.data.ResourceType;

@:build(haxe.ui.ComponentBuilder.build("assets/dialogs/permission-checker.xml"))
class PermissionCheckerDialog extends Dialog {
    public function new() {
        super();
        buttons = "Check" | DialogButton.CLOSE;
    }

    public override function onReady() {
        super.onReady();
        populateUsers();
    }

    private function populateUsers() {
        var ds = new ArrayDataSource<Dynamic>();
        for (user in InternalDB.users.data) {
            ds.add({
                text: user.username,
                userId: user.userId
            });
        }
        userSelector.dataSource = ds;
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

    public override function validateDialog(button:DialogButton, cb:Bool->Void) {
        if (button == "Check") {
            var userId = userSelector.selectedItem.userId;
            var resourceType = Std.parseInt(resourceTypeSelector.selectedItem.resourceType);
            var resourceId = resourceSelector.selectedItem.resourceId;
            var permissionAction = Std.parseInt(actionSelector.selectedItem.actionType);
    
            var hasPermission = false;
            var user = InternalDB.users.utils.user(userId);
            trace("checking permissions for: " + user.userId, resourceType, resourceId, permissionAction);
            var groups = InternalDB.users.utils.groups(userId);
            trace("user belongs to following groups:");
            for (group in groups) {
                trace("    " + group.name);
                var roles = InternalDB.userGroups.utils.roles(group.userGroupId);
                for (role in roles) {
                    trace("        " + role.name);
                    for (permission in InternalDB.roles.utils.permissions(role.roleId)) {
                        if (permission.resourceId == resourceId && permission.resourceType == resourceType && permission.permissionAction == permissionAction) {
                            hasPermission = true;
                        }
                    }
                }
            }

            hasPermission = InternalDB.users.utils.hasPermission(userId, resourceType, resourceId, permissionAction);
            if (hasPermission) {
                resultLabel.text = "User has permission";
            } else {
                resultLabel.text = "User does not have permission";
            }
            cb(false);
        } else {
            cb(true);
        }
    }
}