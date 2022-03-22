package core.data;

import js.lib.Promise;
import core.data.dao.Database;
import core.data.utils.PromiseUtils;

class InternalDB extends Database {
    public static var organizations:CachedDataTable<OrganizationDataTable, OrganizationData, NullUtils>;
    public static var users:CachedDataTable<UserDataTable, UserData, NullUtils>;
    public static var userGroups:CachedDataTable<UserGroupDataTable, UserGroupData, NullUtils>;
    public static var userOrganizationLinks:CachedDataTable<UserOrganizationLinkDataTable, UserOrganizationLinkData, NullUtils>;
    public static var dashboards:CachedDataTable<DashboardDataTable, DashboardData, DashboardUtils>;
    public static var dashboardGroups:CachedDataTable<DashboardGroupDataTable, DashboardGroupData, NullUtils>;
    public static var icons:CachedDataTable<IconDataTable, IconData, NullUtils>;
    public static var roles:CachedDataTable<RoleDataTable, RoleData, NullUtils>;
    public static var permissions:CachedDataTable<PermissionDataTable, PermissionData, NullUtils>;

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
        
        registerTable(OrganizationDataTable.TableName, organizationData);
        registerTable(UserDataTable.TableName, userData);
        registerTable(UserGroupDataTable.TableName, userGroupData);
        registerTable(UserOrganizationLinkDataTable.TableName, userOrganizationLinkData);
        registerTable(DashboardDataTable.TableName, dashboardData);
        registerTable(DashboardGroupDataTable.TableName, dashboardGroupData);
        registerTable(IconDataTable.TableName, iconData);
        registerTable(RoleDataTable.TableName, roleData);
        registerTable(PermissionDataTable.TableName, permissionData);

        caches.organizations = new CachedDataTable<OrganizationDataTable, OrganizationData, NullUtils>(organizationData);
        caches.users = new CachedDataTable<UserDataTable, UserData, NullUtils>(userData);
        caches.userGroups = new CachedDataTable<UserGroupDataTable, UserGroupData, NullUtils>(userGroupData);
        caches.userOrganizationLinks = new CachedDataTable<UserOrganizationLinkDataTable, UserOrganizationLinkData, NullUtils>(userOrganizationLinkData);
        caches.dashboards = new CachedDataTable<DashboardDataTable, DashboardData, DashboardUtils>(dashboardData, new DashboardUtils());
        caches.dashboardGroups = new CachedDataTable<DashboardGroupDataTable, DashboardGroupData, NullUtils>(dashboardGroupData);
        caches.icons = new CachedDataTable<IconDataTable, IconData, NullUtils>(iconData);
        caches.roles= new CachedDataTable<RoleDataTable, RoleData, NullUtils>(roleData);
        caches.permissions = new CachedDataTable<PermissionDataTable, PermissionData, NullUtils>(permissionData);

        InternalDB.organizations = caches.organizations;
        InternalDB.users = caches.users;
        InternalDB.userGroups = caches.userGroups;
        InternalDB.userOrganizationLinks = caches.userOrganizationLinks;
        InternalDB.dashboards = caches.dashboards;
        InternalDB.dashboardGroups = caches.dashboardGroups;
        InternalDB.icons = caches.icons;
        InternalDB.roles = caches.roles;
        InternalDB.permissions = caches.permissions;
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
                permissionData.init()
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
                caches.permissions.fillCache()
            ];

            PromiseUtils.runSequentially(promises, function() {
                resolve(true);
            });
        });
    }
}