package core.components.dialogs.markers;

import haxe.ui.containers.dialogs.Dialog;

@:build(haxe.ui.ComponentBuilder.build("core/assets/ui/dialogs/markers/static-y-marker-config.xml"))
class StaticYMarkerConfigDialog extends MarkerConfigDialog {
    public function new() {
        super();
        buttons = DialogButton.CANCEL | DialogButton.APPLY;
    }

    public override function onReady() {
        super.onReady();
        if (_markerParams != null) {
            if (_markerParams[0] != null) {
                fieldValue.text = _markerParams[0];
            }
        }
    }

    private override function validateDialog(button:DialogButton, cb:Bool->Void) {
        if (button == DialogButton.APPLY) {
            _markerParams = [fieldValue.text];
        }
        cb(true);
    }
}