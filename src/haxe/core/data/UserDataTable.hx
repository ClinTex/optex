package core.data;

import core.data.dao.IDataTable;

@:build(core.data.dao.Macros.buildDataTable(UserData))
class UserDataTable implements IDataTable<UserData> {
}
