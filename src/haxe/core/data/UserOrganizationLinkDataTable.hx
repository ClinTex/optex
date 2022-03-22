package core.data;

import core.data.dao.IDataTable;

@:build(core.data.dao.Macros.buildDataTable(UserOrganizationLinkData))
class UserOrganizationLinkDataTable implements IDataTable<UserOrganizationLinkData> {
}
