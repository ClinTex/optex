package core.data;

import core.data.dao.IDataTable;

@:build(core.data.dao.Macros.buildDataTable(SiteData))
class SiteDataTable implements IDataTable<SiteData> {
}
