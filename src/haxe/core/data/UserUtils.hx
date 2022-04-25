package core.data;

import js.lib.Promise;
import core.data.utils.PromiseUtils;

class UserUtils {
    public function new() {
    }

    public function user(userId:Int):UserData {
        var user = null;
        for (u in InternalDB.users.data) {
            if (u.userId == userId) {
                user = u;
                break;
            }
        }
        return user;
    }

    public function groups(userId:Int):Array<UserGroupData> {
        var groups = [];
        for (link in InternalDB.userGroupLinks.data) {
            if (link.userId == userId) {
                var group = InternalDB.userGroups.utils.group(link.userGroupId);
                if(group != null) {
                    groups.push(group);
                }
            }
        }
        return groups;
    }

    public function permissions(userId:Int):Array<PermissionData> {
        var list = [];
        for (group in groups(userId)) {
            var roles = InternalDB.userGroups.utils.roles(group.userGroupId);
            for (role in roles) {
                for (permission in InternalDB.roles.utils.permissions(role.roleId)) {
                    list.push(permission);
                }
            }
        }
        return list;
    }

    public function hasPermission(userId:Int, resourceType:Int, resourceId:Int, permissionAction:Int) {
        var has = false;
        for (permission in permissions(userId)) {
            if ((permission.resourceId == resourceId || permission.resourceId == -1)
                && permission.resourceType == resourceType
                && permission.permissionAction == permissionAction) {
                has = true;
                break;
            }
        }
        return has;
    }

    public function cascadeRemove(userId):Promise<Bool> {
        return new Promise((resolve, reject) -> {
            var promises = [];
            for (link in InternalDB.userOrganizationLinks.data) {
                if (link.userId == userId) {
                    promises.push(InternalDB.userOrganizationLinks.removeObject(link));
                }
            }
            promises.push(InternalDB.users.removeObject(user(userId)));
            
            PromiseUtils.runSequentially(promises, function() {
                resolve(true);
            });
        });
    }
}