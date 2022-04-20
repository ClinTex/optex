package sidebars;

import views.OrganizationsView;
import core.data.InternalDB;
import core.data.OrganizationData;

@:build(haxe.ui.ComponentBuilder.build("assets/sidebars/create-user.xml"))
class CreateUserSidebar extends DataObjectSidebar {
    public var organization:OrganizationData;

    public function new() {
        super();
    }

    public override function onReady() {
        super.onReady();
        title.text = "New User - " + organization.name;
    }

    private override function createObject() {
        var user = InternalDB.users.createObject();
        user.username = userUsernameField.text;
        user.password = userPasswordField.text;
        user.firstName = userFirstNameField.text;
        user.lastName = userLastNameField.text;
        user.emailAddress = userEmailField.text;
        user.isAdmin = false;

        InternalDB.users.addObject(user).then(function(r) {
            var userLink = InternalDB.userOrganizationLinks.createObject();
            userLink.userId = user.userId;
            userLink.organizationId = organization.organizationId;
            
            InternalDB.userOrganizationLinks.addObject(userLink).then(function(r) {
                createComplete();
                OrganizationsView.instance.populateOrgs();
            });
        });
    }
}