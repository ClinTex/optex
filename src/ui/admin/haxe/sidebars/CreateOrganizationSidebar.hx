package sidebars;

import core.data.InternalDB;
import views.OrganizationsView;

@:build(haxe.ui.ComponentBuilder.build("assets/sidebars/create-org.xml"))
class CreateOrganizationSidebar extends DataObjectSidebar {
    public function new() {
        super();
    }

    private override function createObject() {
        var org = InternalDB.organizations.createObject();
        org.name = orgNameField.text;

        InternalDB.organizations.addObject(org).then(function(r) {
            createComplete();
            OrganizationsView.instance.populateOrgs();
        });
    }
}