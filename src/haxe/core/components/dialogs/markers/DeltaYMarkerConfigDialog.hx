package core.components.dialogs.markers;

import haxe.ui.containers.dialogs.Dialog;

@:build(haxe.ui.ComponentBuilder.build("core/assets/ui/dialogs/markers/delta-y-marker-config.xml"))
class DeltaYMarkerConfigDialog extends MarkerConfigDialog {
    public function new() {
        super();
        buttons = DialogButton.CANCEL | DialogButton.APPLY;
    }

    public override function onReady() {
        super.onReady();
        if (_markerParams != null) {
            if (_markerParams[0] != null) {
                series1Index.text = _markerParams[0];
            }
            if (_markerParams[1] != null) {
                series2Index.text = _markerParams[1];
            }
        }
    }

    private override function validateDialog(button:DialogButton, cb:Bool->Void) {
        if (button == DialogButton.APPLY) {
            _markerParams = [series1Index.text, series2Index.text];
        }
        cb(true);
    }
}