package core.data;

class RoleUtils {
    public function new() {
    }

    public function role(roleId:Int):RoleData {
        var role = null;
        for (r in InternalDB.roles.data) {
            if (r.roleId == roleId) {
                role = r;
                break;
            }
        }
        return role;
    }

    public function permissions(roleId:Int):Array<PermissionData> {
        var list = [];
        for (p in InternalDB.permissions.data) {
            if (p.roleId == roleId) {
                list.push(p);
            }
        }
        return list;
    }
}