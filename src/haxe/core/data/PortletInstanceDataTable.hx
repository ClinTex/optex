package core.data;

import core.data.dao.IDataTable;

@:build(core.data.dao.Macros.buildDataTable(PortletInstanceData))
class PortletInstanceDataTable implements IDataTable<PortletInstanceData> {
}
