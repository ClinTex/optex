package sidebars;

import views.OrganizationsView;
import core.data.InternalDB;
import core.data.OrganizationData;

@:build(haxe.ui.ComponentBuilder.build("assets/sidebars/create-user-group.xml"))
class CreateUserGroupSidebar extends DataObjectSidebar {
    public var organization:OrganizationData;

    public function new() {
        super();
    }

    public override function onReady() {
        super.onReady();
        title.text = "New User Group - " + organization.name;
        return value;
    }

    private override function createObject() {
        var userGroup = InternalDB.userGroups.createObject();
        userGroup.name = groupNameField.text;
        userGroup.organizationId = organization.organizationId;

        InternalDB.userGroups.addObject(userGroup).then(function(r) {
            createComplete();
            OrganizationsView.instance.populateOrgs();
        });
    }
}