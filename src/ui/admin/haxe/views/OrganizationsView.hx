package views;

import core.data.InternalDB;
import panels.OrganizationDetailsPanel;
import panels.UserDetailsPanel;
import core.data.UserData;
import haxe.ui.events.UIEvent;
import sidebars.CreateUserGroupSidebar;
import core.data.OrganizationData;
import haxe.ui.containers.TreeViewNode;
import sidebars.CreateRoleSidebar;
import sidebars.CreateUserSidebar;
import sidebars.CreateOrganizationSidebar;
import haxe.ui.events.MouseEvent;
import haxe.ui.Toolkit;
import haxe.ui.containers.VBox;

@:build(haxe.ui.ComponentBuilder.build("assets/views/organizations.xml"))
class OrganizationsView extends VBox {
    public static var instance:OrganizationsView;

    public function new() {
        instance = this;

        super();
    }

    public override function onReady() {
        super.onReady();

        if (!canCreateOrgs()) {
            bottomButtons.hide();
        }

        populateOrgs();
    }

    @:bind(orgsTree, UIEvent.CHANGE)
    private function onOrgsTreeSelectionChanged(e:UIEvent) {
        trace("selection changed");
        var selectedNode = orgsTree.selectedNode;
        if (selectedNode == null) {
            return;
        }

        detailsContainer.removeAllComponents();
        if (selectedNode.data.user != null) {
            var user:UserData = selectedNode.data.user;
            var panel = new UserDetailsPanel();
            detailsContainer.addComponent(panel);
        } else if (selectedNode.data.org != null) {
            var user:OrganizationData = selectedNode.data.org;
            var panel = new OrganizationDetailsPanel();
            detailsContainer.addComponent(panel);
        }
    }

    private function canCreateOrgs() {
        if (AdminView.instance.currentUser.isAdmin) {
            return true;
        }

        return false;
    }

    public function refreshOrgs(orgIdToSelect:Null<Int> = null):TreeViewNode {
        var nodeToSelect = null;
        _orgsNode.clearNodes();
        for (org in InternalDB.organizations.data) {
            var orgNode = _orgsNode.addNode({text: org.name, icon: "themes/optex/sitemap-solid.png", org: org});
            /*
            if (orgIdToSelect != null && org.organizationId == orgIdToSelect) {
                nodeToSelect = orgNode;
            }
            */
            orgNode.expanded = false;
            var usersNode = orgNode.addNode({text: "Users", icon: "themes/optex/folder-solid.png", org: org});
            usersNode.userData = "users";
            usersNode.expanded = true;
            refreshUsers(usersNode, orgNode);

            var userGroupsNode = orgNode.addNode({text: "User Groups", icon: "themes/optex/folder-solid.png", org: org});
            userGroupsNode.userData = "userGroups";
            userGroupsNode.expanded = true;
            refreshUserGroups(userGroupsNode, orgNode);
            
            var rolesNode = orgNode.addNode({text: "Roles", icon: "themes/optex/folder-solid.png", org: org});
            rolesNode.userData = "roles";
            rolesNode.expanded = true;
        }
        return nodeToSelect;
    }

    public function refreshUsers(usersNode:TreeViewNode, orgNode:TreeViewNode) {
        var org:OrganizationData = orgNode.data.org;
        for (userLink in InternalDB.userOrganizationLinks.data) {
            if (userLink.organizationId == org.organizationId) {
                for (user in InternalDB.users.data) {
                    if (user.userId == userLink.userId) {
                        var userLabel = user.username + " (" + user.firstName + " " + user.lastName  + ")";
                        var userNode = usersNode.addNode({text: userLabel, icon: "themes/optex/user-solid.png", org: org, user: user});
                        var groupsNode = userNode.addNode({text: "Groups", icon: "themes/optex/folder-solid.png", org: org, user: user});
                        var rolesNode = userNode.addNode({text: "Roles", icon: "themes/optex/folder-solid.png", org: org, user: user});
                    }
                }
            }
        }
    }

    public function refreshUserGroups(userGroupsNode:TreeViewNode, orgNode:TreeViewNode) {
        var org:OrganizationData = orgNode.data.org;
        for (userGroup in InternalDB.userGroups.data) {
            if (userGroup.organizationId == org.organizationId) {
                var groupLabel = userGroup.name;
                var userGroupNode = userGroupsNode.addNode({text: groupLabel, icon: "themes/optex/user-group-solid.png"});
                var rolesNode = userGroupNode.addNode({text: "Roles", icon: "themes/optex/folder-solid.png", org: org, userGroup: userGroup});
            }
        }
    }

    private var _orgsNode:TreeViewNode;

    public function populateOrgs() {
        orgsTree.clearNodes();
        var nodeToSelect = null;

        if (canCreateOrgs()) {
            _orgsNode = orgsTree.addNode({text: "Organizations", icon: "themes/optex/folder-solid.png"});
            _orgsNode.userData = "orgs";
            _orgsNode.expanded = true;
            nodeToSelect = _orgsNode;
            var node = refreshOrgs();
            if (node != null) {
                nodeToSelect = node;
            }

            /*
            var usersNode = orgsTree.addNode({text: "Users", icon: "haxeui-core/styles/shared/folder-light.png"});
            usersNode.userData = "users";
            usersNode.expanded = true;

            var rolesNode = orgsTree.addNode({text: "Roles", icon: "haxeui-core/styles/shared/folder-light.png"});
            rolesNode.userData = "roles";
            rolesNode.expanded = true;
            */
        } else {
            _orgsNode = orgsTree.addNode({text: "My Organizations", icon: "themes/optex/folder-solid.png"});
            _orgsNode.expanded = true;
            nodeToSelect = _orgsNode;

            /*
            var rolesNode = orgsTree.addNode({text: "My Roles", icon: "haxeui-core/styles/shared/folder-light.png"});
            rolesNode.userData = "roles";
            rolesNode.expanded = true;
            */
        }

        if (nodeToSelect != null) {
            Toolkit.callLater(function() {
                orgsTree.selectedNode = nodeToSelect;
            });
        }
    }

    @:bind(addButton, MouseEvent.CLICK)
    private function onAddButton(e:MouseEvent) {
        var selectedNode = orgsTree.selectedNode;
        if (selectedNode == null) {
            return;
        }

        trace(selectedNode.userData);
        switch (selectedNode.userData) {
            case "orgs":
                var sidebar = new CreateOrganizationSidebar();
                sidebar.position = "right";
                sidebar.modal = true;
                sidebar.show();
            case "users":
                var org:OrganizationData = selectedNode.data.org;
                var sidebar = new CreateUserSidebar();
                sidebar.organization = org;
                sidebar.position = "right";
                sidebar.modal = true;
                sidebar.show();
            case "userGroups":
                var org:OrganizationData = selectedNode.data.org;
                var sidebar = new CreateUserGroupSidebar();
                sidebar.organization = org;
                sidebar.position = "right";
                sidebar.modal = true;
                sidebar.show();
            case "roles":
                var sidebar = new CreateRoleSidebar();
                sidebar.position = "right";
                sidebar.modal = true;
                sidebar.show();
        }
    }
}