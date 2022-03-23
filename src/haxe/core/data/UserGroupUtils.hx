package core.data;

class UserGroupUtils {
    public function new() {
    }

    public function group(userGroupId:Int):UserGroupData {
        var group = null;
        for (g in InternalDB.userGroups.data) {
            if (g.userGroupId == userGroupId) {
                group = g;
                break;
            }
        }
        return group;
    }

    public function users(userGroupId:Int):Array<UserData> {
        var users = [];

        for (userGroupLink in InternalDB.userGroupLinks.data) {
            if (userGroupLink.userGroupId == userGroupId) {
                var user = InternalDB.users.utils.user(userGroupLink.userId);
                if (user != null) {
                    users.push(user);
                }
            }
        }

        return users;
    }
}