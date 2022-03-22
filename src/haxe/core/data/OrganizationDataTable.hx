package core.data;

import core.data.dao.IDataTable;

@:build(core.data.dao.Macros.buildDataTable(OrganizationData))
class OrganizationDataTable implements IDataTable<OrganizationData> {
}
