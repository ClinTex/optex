package core.data;

import core.data.dao.IDataTable;

@:build(core.data.dao.Macros.buildDataTable(DashboardGroupData))
class DashboardGroupDataTable implements IDataTable<DashboardGroupData> {
}