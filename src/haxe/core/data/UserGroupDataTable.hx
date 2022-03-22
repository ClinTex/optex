package core.data;

import core.data.dao.IDataTable;

@:build(core.data.dao.Macros.buildDataTable(UserGroupData))
class UserGroupDataTable implements IDataTable<UserGroupData> {
}
