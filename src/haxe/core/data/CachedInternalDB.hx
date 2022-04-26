package core.data;

class CachedInternalDB {
    public var organizations:CachedDataTable<OrganizationDataTable, OrganizationData, NullUtils>;
    public var users:CachedDataTable<UserDataTable, UserData, UserUtils>;
    public var userGroups:CachedDataTable<UserGroupDataTable, UserGroupData, UserGroupUtils>;
    public var userOrganizationLinks:CachedDataTable<UserOrganizationLinkDataTable, UserOrganizationLinkData, NullUtils>;
    public var dashboards:CachedDataTable<DashboardDataTable, DashboardData, DashboardUtils>;
    public var dashboardGroups:CachedDataTable<DashboardGroupDataTable, DashboardGroupData, NullUtils>;
    public var icons:CachedDataTable<IconDataTable, IconData, IconUtils>;
    public var roles:CachedDataTable<RoleDataTable, RoleData, RoleUtils>;
    public var permissions:CachedDataTable<PermissionDataTable, PermissionData, NullUtils>;
    public var userGroupLinks:CachedDataTable<UserUserGroupLinkDataTable, UserUserGroupLinkData, NullUtils>;
    public var userGroupRoleLinks:CachedDataTable<UserGroupRoleLinkDataTable, UserGroupRoleLinkData, NullUtils>;
    public var sites:CachedDataTable<SiteDataTable, SiteData, SiteUtils>;
    public var pages:CachedDataTable<PageDataTable, PageData, PageUtils>;
    public var layouts:CachedDataTable<LayoutDataTable, LayoutData, LayoutUtils>;
    public var portletInstances:CachedDataTable<PortletInstanceDataTable, PortletInstanceData, PortletInstanceUtils>;
    public var dataSources:CachedDataTable<DataSourceDataTable, DataSourceData, DataSourceUtils>;

    public function new() {
    }
}