package core.data;

class CachedInternalDB {
    public var organizations:CachedDataTable<OrganizationDataTable, OrganizationData, NullUtils>;
    public var users:CachedDataTable<UserDataTable, UserData, NullUtils>;
    public var userGroups:CachedDataTable<UserGroupDataTable, UserGroupData, NullUtils>;
    public var userOrganizationLinks:CachedDataTable<UserOrganizationLinkDataTable, UserOrganizationLinkData, NullUtils>;
    public var dashboards:CachedDataTable<DashboardDataTable, DashboardData, DashboardUtils>;
    public var dashboardGroups:CachedDataTable<DashboardGroupDataTable, DashboardGroupData, NullUtils>;
    public var icons:CachedDataTable<IconDataTable, IconData, NullUtils>;
    public var roles:CachedDataTable<RoleDataTable, RoleData, NullUtils>;
    public var permissions:CachedDataTable<PermissionDataTable, PermissionData, NullUtils>;

    public function new() {
    }
}