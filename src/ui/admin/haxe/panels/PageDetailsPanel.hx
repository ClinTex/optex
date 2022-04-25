package panels;

import core.data.PortletInstanceData;
import core.components.portlets.PortletInstance;
import core.components.portlets.PortletEvent;
import haxe.ui.containers.dialogs.Dialog.DialogEvent;
import dialogs.SelectPortletDialog;
import haxe.ui.events.MouseEvent;
import haxe.ui.containers.Box;
import core.data.LayoutData;
import views.OrganizationsView;
import components.WorkingIndicator;
import haxe.ui.components.Button;
import core.data.PageData;
import haxe.ui.containers.VBox;
import core.data.InternalDB;
import core.components.portlets.PortletFactory;

@:build(haxe.ui.ComponentBuilder.build("assets/panels/page-details.xml"))
class PageDetailsPanel extends VBox {
	public var pageDetails:PageData;

	public function new() {
		super();
		findComponent("updateButton", Button).onClick = function(_) {
			onUpdate();
		}
        pageLayoutPreview.registerEvent(PortletEvent.ASSIGN_PORTLET_CLICKED, onPortletAssignPortletClicked);
	}

    private function onPortletAssignPortletClicked(event:PortletEvent) {
        var portletContainer = event.portletContainer;
        trace("assign portlet! " + portletContainer.id);
        var portletContainerId:String = portletContainer.id;

        var dialog = new SelectPortletDialog();
        dialog.onDialogClosed = function(e:DialogEvent) {
            if (e.button == "Select") {
                var selectedClassName = dialog.portletTypeSelector.selectedItem.className;
                trace("selected: " + selectedClassName);

                var portletInstance = PortletFactory.instance.createInstance(selectedClassName);
                pageLayoutPreview.assignPortletInstance(portletContainerId, portletInstance);
            }
        }
        dialog.show();

    }

	public override function onReady() {
		super.onReady();

		pageNameField.text = pageDetails.name;

		var layout:LayoutData = InternalDB.layouts.utils.layout(pageDetails.layoutId);
		pageLayoutPreview.layoutData = layout.layoutData;
        pageLayoutPreview.assignPortletInstancesFromPage(pageDetails.pageId);
	}

	private var _working:WorkingIndicator;
	private function onUpdate() {
		pageDetails.name = pageNameField.text;

        var portletContainers = pageLayoutPreview.portletContainers;
        var portletInstances:Array<PortletInstance> = [];
        for (portletContainer in portletContainers) {
            var portletInstance = portletContainer.portletInstance;
            if (portletInstance != null) {
                trace("-----> " + portletContainer.id + ", " + portletInstance.className);
                portletInstances.push(portletInstance);
            }
        }

        var portletsToAssign = [];
        for (portletInstance in portletInstances) {
            var portletDetails:PortletInstanceData = portletInstance.portletDetails;
            portletsToAssign.push(portletDetails);
            trace(portletDetails.portletData, portletDetails.layoutData);
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
