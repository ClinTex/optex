package core.data;

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
}