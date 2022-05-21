package core.components.portlets;

import haxe.ui.containers.TreeViewNode;
import haxe.ui.containers.TreeView;
import core.data.InternalDB;

class SiteMapPortletInstance extends PortletInstance {
    private var _tree:TreeView = null;

    private override function onReady() {
        super.onReady();
        _tree = new TreeView();
        _tree.percentWidth = 100;
        _tree.percentHeight = 100;
        addComponent(_tree);
        buildSiteMap();
    }

    private function buildSiteMap() {
        var siteId = this.page.pageDetails.siteId;
        buildPageLinks(siteId, -1, null);
    }

    private function buildPageLinks(siteId:Int, parentPageId:Int, node:TreeViewNode) {
        var pages = InternalDB.pages.utils.sitePages(siteId, parentPageId);
        if (pages.length == 0) {
            return;
        }

        for (page in pages) {
            var pageNode = null;
            var pageLabel = page.name;
            var pageIcon = "themes/optex/" + InternalDB.icons.utils.icon(page.iconId).path;
            if (node == null) {
                pageNode = _tree.addNode({text: pageLabel, icon: pageIcon, page: page});
            } else {
                pageNode = node.addNode({text: pageLabel, icon: pageIcon, page: page});
            }
            pageNode.expanded = true;
            buildPageLinks(siteId, page.pageId, pageNode);
        }
    }
}