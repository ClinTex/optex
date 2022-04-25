package sidebars;

import views.OrganizationsView;
import core.data.IconData;
import core.data.InternalDB;
import core.data.PageData;
import core.data.SiteData;

@:build(haxe.ui.ComponentBuilder.build("assets/sidebars/create-site-page.xml"))
class CreateSitePageSidebar extends DataObjectSidebar {
    public var site:SiteData;
    public var parentPage:PageData;

    public function new() {
        super();
    }
    
    public override function onReady() {
        super.onReady();
        if (parentPage != null) {
            title.text = "New Site Page - " + parentPage.name;
        }
    }

    private override function createObject() {
        var page = InternalDB.pages.createObject();
        page.name = pageNameField.text;
        page.siteId = site.siteId;
        if (parentPage != null) {
            page.parentPageId = parentPage.pageId;
        } else {
            page.parentPageId = -1;
        }
        var iconData:IconData = pageIconSelector.selectedItem.iconData;
        page.iconId = iconData.iconId;
        page.layoutId = 1;

        InternalDB.pages.addObject(page).then(function(r) {
            OrganizationsView.instance.populateOrgs();
            createComplete();
        });
    }
}