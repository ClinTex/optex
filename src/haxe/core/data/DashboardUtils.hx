package core.data;

class DashboardUtils {
    public function new() {
    }

    public var byGroup(get, null):Map<DashboardGroupData, Array<DashboardData>>;
    private function get_byGroup():Map<DashboardGroupData, Array<DashboardData>> {
        var map:Map<DashboardGroupData, Array<DashboardData>> = [];
        for (d in InternalDB.dashboards.data) {
            var group = d.group;
            if (group == null) {
                group = new DashboardGroupData();
                group.icon = new IconData();
                group.name = "Unknown";
            }
            var list = map.get(group);
            if (list == null) {
                list = [];
                map.set(group, list);
            }
            list.push(d);
        }

        return map;
    }
}