package core.components.dialogs.transforms;

import haxe.ui.containers.dialogs.Dialog;

using StringTools;

@:build(haxe.ui.ComponentBuilder.build("core/assets/ui/dialogs/transforms/average-transform-config.xml"))
class AverageTransformConfigDialog extends TransformConfigDialog {
    public function new() {
        super();
        buttons = DialogButton.CANCEL | DialogButton.APPLY;
    }

    public override function onReady() {
        super.onReady();
        buildDataSourceFieldListFor(fieldSelector);
        var param = _transformParams[0];
        if (param != null) {
            param = param.substr(1, param.length - 2);
            if (param.startsWith("$")) {
                fieldFromFilter.selected = true;
                param = param.substr(1, param.length -1);
            }
            fieldSelector.selectedItem = param;
        }
    }

    private override function validateDialog(button:DialogButton, cb:Bool->Void) {
        if (button == DialogButton.APPLY) {
            var fieldName = fieldSelector.selectedItem.fieldName;
            if (fieldFromFilter.selected == true) {
                fieldName = "$" + fieldName;
            }
            fieldName = "'" + fieldName + "'";
            _transformParams = [fieldName];
        }
        cb(true);
    }
}