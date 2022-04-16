package panels;

import views.OrganizationsView;
import components.WorkingIndicator;
import haxe.ui.components.Button;
import core.data.LayoutData;
import haxe.ui.containers.VBox;
import core.data.InternalDB;

@:build(haxe.ui.ComponentBuilder.build("assets/panels/layout-details.xml"))
class LayoutDetailsPanel extends VBox {
    public var layoutDetails:LayoutData;

    public function new() {
        super();
        findComponent("updateButton", Button).onClick = function(_) {
            onUpdate();
        }
    }

   public override function onReady() {
       super.onReady();

       layoutNameField.text = layoutDetails.name;
       layoutDataField.text = layoutDetails.layoutData;
   }

   private var _working:WorkingIndicator;
   private function onUpdate() {

        layoutDetails.name = layoutNameField.text;
        layoutDetails.layoutData = layoutDataField.text;

        _working = new WorkingIndicator();
        _working.showWorking();
        InternalDB.layouts.updateObject(layoutDetails).then(function(r) {
            OrganizationsView.instance.populateOrgs();
            _working.workComplete();
        });
   }
}