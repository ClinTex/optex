package panels;

import haxe.ui.data.ArrayDataSource;
import core.data.PortletInstanceData;
import core.components.portlets.PortletInstance;
import core.data.LayoutData;
import views.OrganizationsView;
import components.WorkingIndicator;
import haxe.ui.components.Button;
import core.data.PageData;
import haxe.ui.containers.VBox;
import core.data.InternalDB;

@:build(haxe.ui.ComponentBuilder.build("assets/panels/page-details.xml"))
class PageDetailsPanel extends VBox {
	public var pageDetails:PageData;

	public function new() {
		super();
		findComponent("updateButton", Button).onClick = function(_) {
			onUpdate();
		}
	}

	public override function onReady() {
		super.onReady();

		pageNameField.text = pageDetails.name;
        var ds = new ArrayDataSource<Dynamic>();
        var indexToSelect = 0;
        var n = 0;
        for (layout in InternalDB.layouts.utils.availableLayoutsForPage(pageDetails.pageId)) {
            if (layout.layoutId == pageDetails.layoutId) {
                indexToSelect = n;
            }
            ds.add({
                text: layout.name,
                layout: layout
            });
            n++;
        }
        layoutSelector.dataSource = ds;
        layoutSelector.selectedIndex = indexToSelect;

		var layout:LayoutData = InternalDB.layouts.utils.layout(pageDetails.layoutId);
		pageLayoutPreview.layoutData = layout.layoutData;
        pageLayoutPreview.loadPage(pageDetails.pageId);
	}

	private var _working:WorkingIndicator;
	private function onUpdate() {
		pageDetails.name = pageNameField.text;
        var layout:LayoutData = layoutSelector.selectedItem.layout;
        pageDetails.layoutId = layout.layoutId;

        var portletContainers = pageLayoutPreview.portletContainers;
        var portletInstances:Array<PortletInstance> = [];
        for (portletContainer in portletContainers) {
            var portletInstance = portletContainer.portletInstance;
            if (portletInstance != null) {
                portletInstances.push(portletInstance);
            }
        }

        var portletsToAssign = [];
        for (portletInstance in portletInstances) {
            var portletDetails:PortletInstanceData = portletInstance.portletDetails;
            portletsToAssign.push(portletDetails);
        }

		_working = new WorkingIndicator();
		_working.showWorking();
		InternalDB.pages.updateObject(pageDetails).then(function(r) {
            InternalDB.pages.utils.assignPortletInstances(pageDetails.pageId, portletsToAssign).then(function(r) {
                OrganizationsView.instance.populateOrgs();
                _working.workComplete();
            });
		});
	}
}
