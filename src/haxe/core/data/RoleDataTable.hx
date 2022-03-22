package core.data;

import core.data.dao.IDataTable;

@:build(core.data.dao.Macros.buildDataTable(RoleData))
class RoleDataTable implements IDataTable<RoleData> {
}
