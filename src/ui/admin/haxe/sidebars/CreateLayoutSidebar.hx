package sidebars;

import views.OrganizationsView;
import core.data.InternalDB;
import core.data.OrganizationData;

@:build(haxe.ui.ComponentBuilder.build("assets/sidebars/create-layout.xml"))
class CreateLayoutSidebar extends DataObjectSidebar {
    public var organization:OrganizationData;

    public function new() {
        super();
    }

    public override function onReady() {
        super.onReady();
        title.text = "New Layout - " + organization.name;
    }

    private override function createObject() {
        var layout = InternalDB.layouts.createObject();
        layout.name = layoutNameField.text;
        layout.organizationId = organization.organizationId;
        layout.layoutData = "<layout />";

        InternalDB.layouts.addObject(layout).then(function(r) {
            OrganizationsView.instance.populateOrgs();
            createComplete();
        });
    }
}