package panels;

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
                var selectedType = dialog.portletTypeSelector.selectedItem.type;
                trace("selected: " + selectedType);

                var portletInstance = PortletFactory.instance.createInstance(selectedType);
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

        /*
		var portletContainers = pageLayoutPreview.findComponents("portlet-container", Box, 0xffffff);
		for (portletContainer in portletContainers) {
			var image = new Image();
			image.resource = "icons/icons8-plus-+-32.png";
			image.verticalAlign = "center";
			image.horizontalAlign = "center";
			image.userData = portletContainer.id;
            image.styleString = "cursor:pointer;";
			image.onClick = onAddImageClick;
			portletContainer.addComponent(image);
		}
        */
	}

	private function onAddImageClick(e:MouseEvent) {
        var portletContainerId:String = e.target.userData;
        trace(portletContainerId);

        var dialog = new SelectPortletDialog();
        dialog.onDialogClosed = function(e:DialogEvent) {
            if (e.button == "Select") {
                var selectedType = dialog.portletTypeSelector.selectedItem.type;
                trace("selected: " + selectedType);

                var portletContainer = pageLayoutPreview.findComponent(portletContainerId, Box);
                var portletInstance = PortletFactory.instance.createInstance(selectedType);
                portletContainer.removeAllComponents();
                portletContainer.addComponent(portletInstance);
            }
        }
        dialog.show();
    }

	private var _working:WorkingIndicator;

	private function onUpdate() {
		pageDetails.name = pageNameField.text;

		_working = new WorkingIndicator();
		_working.showWorking();
		InternalDB.pages.updateObject(pageDetails).then(function(r) {
			OrganizationsView.instance.populateOrgs();
			_working.workComplete();
		});
	}
}
