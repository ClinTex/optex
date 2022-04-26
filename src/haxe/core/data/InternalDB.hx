package core.data;

import js.lib.Promise;
import core.data.dao.Database;
import core.data.utils.PromiseUtils;

class InternalDB extends Database {
    public static var organizations:CachedDataTable<OrganizationDataTable, OrganizationData, NullUtils>;
    public static var users:CachedDataTable<UserDataTable, UserData, UserUtils>;
    public static var userGroups:CachedDataTable<UserGroupDataTable, UserGroupData, UserGroupUtils>;
    public static var userOrganizationLinks:CachedDataTable<UserOrganizationLinkDataTable, UserOrganizationLinkData, NullUtils>;
    public static var dashboards:CachedDataTable<DashboardDataTable, DashboardData, DashboardUtils>;
    public static var dashboardGroups:CachedDataTable<DashboardGroupDataTable, DashboardGroupData, NullUtils>;
    public static var icons:CachedDataTable<IconDataTable, IconData, IconUtils>;
    public static var roles:CachedDataTable<RoleDataTable, RoleData, RoleUtils>;
    public static var permissions:CachedDataTable<PermissionDataTable, PermissionData, NullUtils>;
    public static var userGroupLinks:CachedDataTable<UserUserGroupLinkDataTable, UserUserGroupLinkData, NullUtils>;
    public static var userGroupRoleLinks:CachedDataTable<UserGroupRoleLinkDataTable, UserGroupRoleLinkData, NullUtils>;
    public static var sites:CachedDataTable<SiteDataTable, SiteData, SiteUtils>;
    public static var pages:CachedDataTable<PageDataTable, PageData, PageUtils>;
    public static var layouts:CachedDataTable<LayoutDataTable, LayoutData, LayoutUtils>;
    public static var portletInstances:CachedDataTable<PortletInstanceDataTable, PortletInstanceData, PortletInstanceUtils>;
    public static var dataSources:CachedDataTable<DataSourceDataTable, DataSourceData, DataSourceUtils>;

    private static var _instance:InternalDB = null;
    public static var instance(get, null):InternalDB;
    private static function get_instance():InternalDB {
        if (_instance == null) {
            _instance = new InternalDB();
        }
        return _instance;
    }

    private var organizationData:OrganizationDataTable;
    private var userData:UserDataTable;
    private var userGroupData:UserGroupDataTable;
    private var userOrganizationLinkData:UserOrganizationLinkDataTable;
    private var dashboardData:DashboardDataTable;
    private var dashboardGroupData:DashboardGroupDataTable;
    private var iconData:IconDataTable;
    private var roleData:RoleDataTable;
    private var permissionData:PermissionDataTable;
    private var userGroupLinkData:UserUserGroupLinkDataTable;
    private var userGroupRoleLinkData:UserGroupRoleLinkDataTable;
    private var siteData:SiteDataTable;
    private var pageData:PageDataTable;
    private var layoutData:LayoutDataTable;
    private var portletInstanceData:PortletInstanceDataTable;
    private var dataSourceData:DataSourceDataTable;

    public var caches = new CachedInternalDB();

    public function new() {
        super();
        
        name = "__optex_data";
        
        organizationData = new OrganizationDataTable();
        userData = new UserDataTable();
        userGroupData = new UserGroupDataTable();
        userOrganizationLinkData = new UserOrganizationLinkDataTable();
        dashboardData = new DashboardDataTable();
        dashboardGroupData = new DashboardGroupDataTable();
        iconData = new IconDataTable();
        roleData = new RoleDataTable();
        permissionData = new PermissionDataTable();
        userGroupLinkData = new UserUserGroupLinkDataTable();
        userGroupRoleLinkData = new UserGroupRoleLinkDataTable();
        siteData = new SiteDataTable();
        pageData = new PageDataTable();
        layoutData = new LayoutDataTable();
        portletInstanceData = new PortletInstanceDataTable();
        dataSourceData = new DataSourceDataTable();
        
        registerTable(OrganizationDataTable.TableName, organizationData);
        registerTable(UserDataTable.TableName, userData);
        registerTable(UserGroupDataTable.TableName, userGroupData);
        registerTable(UserOrganizationLinkDataTable.TableName, userOrganizationLinkData);
        registerTable(DashboardDataTable.TableName, dashboardData);
        registerTable(DashboardGroupDataTable.TableName, dashboardGroupData);
        registerTable(IconDataTable.TableName, iconData);
        registerTable(RoleDataTable.TableName, roleData);
        registerTable(PermissionDataTable.TableName, permissionData);
        registerTable(UserUserGroupLinkDataTable.TableName, userGroupLinkData);
        registerTable(UserGroupRoleLinkDataTable.TableName, userGroupRoleLinkData);
        registerTable(SiteDataTable.TableName, siteData);
        registerTable(PageDataTable.TableName, pageData);
        registerTable(LayoutDataTable.TableName, layoutData);
        registerTable(PortletInstanceDataTable.TableName, portletInstanceData);
        registerTable(DataSourceDataTable.TableName, dataSourceData);

        caches.organizations = new CachedDataTable<OrganizationDataTable, OrganizationData, NullUtils>(organizationData);
        caches.users = new CachedDataTable<UserDataTable, UserData, UserUtils>(userData, new UserUtils());
        caches.userGroups = new CachedDataTable<UserGroupDataTable, UserGroupData, UserGroupUtils>(userGroupData, new UserGroupUtils());
        caches.userOrganizationLinks = new CachedDataTable<UserOrganizationLinkDataTable, UserOrganizationLinkData, NullUtils>(userOrganizationLinkData);
        caches.dashboards = new CachedDataTable<DashboardDataTable, DashboardData, DashboardUtils>(dashboardData, new DashboardUtils());
        caches.dashboardGroups = new CachedDataTable<DashboardGroupDataTable, DashboardGroupData, NullUtils>(dashboardGroupData);
        caches.icons = new CachedDataTable<IconDataTable, IconData, IconUtils>(iconData, new IconUtils());
        caches.roles= new CachedDataTable<RoleDataTable, RoleData, RoleUtils>(roleData, new RoleUtils());
        caches.permissions = new CachedDataTable<PermissionDataTable, PermissionData, NullUtils>(permissionData);
        caches.userGroupLinks = new CachedDataTable<UserUserGroupLinkDataTable, UserUserGroupLinkData, NullUtils>(userGroupLinkData);
        caches.userGroupRoleLinks = new CachedDataTable<UserGroupRoleLinkDataTable, UserGroupRoleLinkData, NullUtils>(userGroupRoleLinkData);
        caches.sites = new CachedDataTable<SiteDataTable, SiteData, SiteUtils>(siteData, new SiteUtils());
        caches.pages = new CachedDataTable<PageDataTable, PageData, PageUtils>(pageData, new PageUtils());
        caches.layouts = new CachedDataTable<LayoutDataTable, LayoutData, LayoutUtils>(layoutData, new LayoutUtils());
        caches.portletInstances = new CachedDataTable<PortletInstanceDataTable, PortletInstanceData, PortletInstanceUtils>(portletInstanceData, new PortletInstanceUtils());
        caches.dataSources = new CachedDataTable<DataSourceDataTable, DataSourceData, DataSourceUtils>(dataSourceData, new DataSourceUtils());

        InternalDB.organizations = caches.organizations;
        InternalDB.users = caches.users;
        InternalDB.userGroups = caches.userGroups;
        InternalDB.userOrganizationLinks = caches.userOrganizationLinks;
        InternalDB.dashboards = caches.dashboards;
        InternalDB.dashboardGroups = caches.dashboardGroups;
        InternalDB.icons = caches.icons;
        InternalDB.roles = caches.roles;
        InternalDB.permissions = caches.permissions;
        InternalDB.userGroupLinks = caches.userGroupLinks;
        InternalDB.userGroupRoleLinks = caches.userGroupRoleLinks;
        InternalDB.sites = caches.sites;
        InternalDB.pages = caches.pages;
        InternalDB.layouts = caches.layouts;
        InternalDB.portletInstances = caches.portletInstances;
        InternalDB.dataSources = caches.dataSources;
    }

    public function init():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            var promises = [
                organizationData.init(),
                userData.init(),
                userGroupData.init(),
                userOrganizationLinkData.init(),
                dashboardData.init(),
                dashboardGroupData.init(),
                iconData.init(),
                roleData.init(),
                permissionData.init(),
                userGroupLinkData.init(),
                userGroupRoleLinkData.init(),
                siteData.init(),
                pageData.init(),
                layoutData.init(),
                portletInstanceData.init(),
                dataSourceData.init()
            ];

            PromiseUtils.runSequentially(promises, function() {
                resolve(true);
            });
        });
    }

    public function start():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            var promises = [
                caches.organizations.fillCache(),
                caches.users.fillCache(),
                caches.userGroups.fillCache(),
                caches.userOrganizationLinks.fillCache(),
                caches.dashboards.fillCache(),
                caches.dashboardGroups.fillCache(),
                caches.icons.fillCache(),
                caches.roles.fillCache(),
                caches.permissions.fillCache(),
                caches.userGroupLinks.fillCache(),
                caches.userGroupRoleLinks.fillCache(),
                caches.sites.fillCache(),
                caches.pages.fillCache(),
                caches.layouts.fillCache(),
                caches.portletInstances.fillCache(),
                caches.dataSources.fillCache()
            ];

            PromiseUtils.runSequentially(promises, function() {
                resolve(true);
            });
        });
    }
}