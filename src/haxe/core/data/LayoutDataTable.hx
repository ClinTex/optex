package core.data;

import core.data.dao.IDataTable;

@:build(core.data.dao.Macros.buildDataTable(LayoutData))
class LayoutDataTable implements IDataTable<LayoutData> {
}
