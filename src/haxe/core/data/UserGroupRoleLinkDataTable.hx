package core.data;

import core.data.dao.IDataTable;

@:build(core.data.dao.Macros.buildDataTable(UserGroupRoleLinkData))
class UserGroupRoleLinkDataTable implements IDataTable<UserGroupRoleLinkData> {
}
