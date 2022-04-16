package sidebars;

import views.OrganizationsView;
import core.data.InternalDB;
import core.data.OrganizationData;

@:build(haxe.ui.ComponentBuilder.build("assets/sidebars/create-site.xml"))
class CreateSiteSidebar extends DataObjectSidebar {
    public var organization:OrganizationData;

    public function new() {
        super();
    }

    public override function onReady() {
        super.onReady();
        title.text = "New Site - " + organization.name;
    }

    private override function createObject() {
        var site = InternalDB.sites.createObject();
        site.name = siteNameField.text;
        site.organizationId = organization.organizationId;

        InternalDB.sites.addObject(site).then(function(r) {
            OrganizationsView.instance.populateOrgs();
            createComplete();
        });
    }
}