package sidebars;

import views.OrganizationsView;
import core.data.InternalDB;
import core.data.OrganizationData;
import haxe.ui.containers.SideBar;

@:build(haxe.ui.ComponentBuilder.build("assets/sidebars/create-role.xml"))
class CreateRoleSidebar extends DataObjectSidebar {
    public var organization:OrganizationData;

    public function new() {
        super();
    }

    public override function onReady() {
        super.onReady();
        title.text = "New Role - " + organization.name;
        return value;
    }

    private override function createObject() {
        /*
        var userGroup = InternalDB.roles.createObject();
        userGroup.name = roleNameField.text;
        userGroup.organizationId = organization.organizationId;

        InternalDB.userGroups.addObject(userGroup).then(function(r) {
            createComplete();
            OrganizationsView.instance.populateOrgs();
        });
        */
    }
}