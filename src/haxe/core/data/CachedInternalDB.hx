package core.data;

class CachedInternalDB {
    public var organizations:CachedDataTable<OrganizationDataTable, OrganizationData, NullUtils>;
    public var users:CachedDataTable<UserDataTable, UserData, UserUtils>;
    public var userGroups:CachedDataTable<UserGroupDataTable, UserGroupData, UserGroupUtils>;
    public var userOrganizationLinks:CachedDataTable<UserOrganizationLinkDataTable, UserOrganizationLinkData, NullUtils>;
    public var dashboards:CachedDataTable<DashboardDataTable, DashboardData, DashboardUtils>;
    public var dashboardGroups:CachedDataTable<DashboardGroupDataTable, DashboardGroupData, NullUtils>;
    public var icons:CachedDataTable<IconDataTable, IconData, NullUtils>;
    public var roles:CachedDataTable<RoleDataTable, RoleData, NullUtils>;
    public var permissions:CachedDataTable<PermissionDataTable, PermissionData, NullUtils>;
    public var userGroupLinks:CachedDataTable<UserUserGroupLinkDataTable, UserUserGroupLinkData, NullUtils>;

    public function new() {
    }
}