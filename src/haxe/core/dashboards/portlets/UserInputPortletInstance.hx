package core.dashboards.portlets;

import haxe.ui.components.Label;
import haxe.ui.layouts.VerticalLayout;
import haxe.ui.containers.VBox;
import haxe.ui.components.NumberStepper;

class UserInputPortletInstance extends PortletInstance {
    private var _promptLabel:Label;
    private var _stepper:NumberStepper;

    public function new() {
        super();
        horizontalAlign = "center";

        var box = new VBox();

        _promptLabel = new Label();
        _promptLabel.horizontalAlign = "center";
        _promptLabel.text = "Enter value:";
        box.addComponent(_promptLabel);

        _stepper = new NumberStepper();
        _stepper.horizontalAlign = "center";
        _stepper.onChange = function(e) {
            if (isReady) {
                dashboardInstance.addFilterItem(config("userInputId"), _stepper.value);
            }
        }
        box.addComponent(_stepper);

        addComponent(box);
    }

    private override function onConfigChanged() {
        _promptLabel.text = config("prompt");
        _stepper.pos = configFloat("initialValue");
    }
}
