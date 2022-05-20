package core.components.dialogs.colors;

import haxe.ui.containers.dialogs.Dialog;

class ColorCalculatorConfigDialog extends Dialog {
    public function new() {
        super();
        buttons = DialogButton.CANCEL | DialogButton.APPLY;
    }

    private var _colorCalcParams:Array<String> = [];
    public var colorCalcParams(get, set):Array<String>;
    private function get_colorCalcParams():Array<String> {
        return _colorCalcParams;
    }
    private function set_colorCalcParams(value:Array<String>):Array<String> {
        _colorCalcParams = value;
        return value;
    }
}