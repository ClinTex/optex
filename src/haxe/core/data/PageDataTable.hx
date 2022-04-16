package core.data;

import core.data.dao.IDataTable;

@:build(core.data.dao.Macros.buildDataTable(PageData))
class PageDataTable implements IDataTable<PageData> {
}
