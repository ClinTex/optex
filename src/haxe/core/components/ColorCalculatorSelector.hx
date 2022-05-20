package core.components;

import haxe.ui.containers.VBox;
import haxe.ui.components.DropDown;
import haxe.ui.containers.HBox;
import haxe.ui.events.UIEvent;
import haxe.ui.components.Button;
import haxe.ui.data.ArrayDataSource;
import core.components.dialogs.colors.ColorCalculatorConfigDialog;
import core.components.dialogs.colors.RangeColorCalculatorConfigDialog;
import haxe.ui.containers.dialogs.Dialog.DialogButton;

using StringTools;

class ColorCalculatorSelector extends VBox {
    private var _colorCalcSelector:DropDown;

    private var _colorCalcParams:Array<String> = null;

    public function new() {
        super();

        var hbox:HBox = new HBox();
        hbox.percentWidth = 100;
        addComponent(hbox);

        _colorCalcSelector = new DropDown();
        _colorCalcSelector.percentWidth = 100;

        hbox.addComponent(_colorCalcSelector);
        var ds = new ArrayDataSource<Dynamic>();
        ds.add({ text: "Default", colorCalcId: "none"});
        ds.add({ text: "Range Based", colorCalcId: "range"});
        _colorCalcSelector.dataSource = ds;

        var configButton = new Button();
        configButton.onClick = onConfig;
        configButton.text = "Configure";
        hbox.addComponent(configButton);
    }

    private override function onReady() {
        super.onReady();
        _colorCalcSelector.onChange = function(_) {
            var event = new UIEvent(UIEvent.CHANGE);
            dispatch(event);
        }
    }

    private var _colorCalcString:String = null;
    public var colorCalcString(get, set):String;
    private function get_colorCalcString():String {
        if (_colorCalcSelector.selectedItem == null) {
            return _colorCalcString;
        }
        var colorCalcId:String = _colorCalcSelector.selectedItem.colorCalcId;
        if (colorCalcId == null) {
            return _colorCalcString;
        }

        if (colorCalcId == "none") {
            return null;
        }

        if (_colorCalcParams != null) {
            _colorCalcString = colorCalcId + "(" + _colorCalcParams.join(", ") + ")";
        } else {
            _colorCalcString = colorCalcId;
        }
        return _colorCalcString;
    }
    private function set_colorCalcString(value:String):String {
        _colorCalcString = value;
        if (_colorCalcString != null) {
            var n = _colorCalcString.indexOf("(");
            var colorCalcId = null;
            if (n == -1) {
                _colorCalcParams = null;
                colorCalcId = _colorCalcString;
            } else {
                colorCalcId = _colorCalcString.substr(0, n);
                var paramString = _colorCalcString.substring(n + 1, _colorCalcString.length - 1);
                var parts = paramString.split(",");
                _colorCalcParams = [];
                for (p in parts) {
                    p = p.trim();
                    _colorCalcParams.push(p);
                }
            }

            var n = 0;
            var ds = _colorCalcSelector.dataSource;
            for (i in 0...ds.size) {
                if (ds.get(i).colorCalcId == colorCalcId) {
                    n = i;
                    break;
                }
            }
            _colorCalcSelector.selectedIndex = n;
        }
        return value;
    }

    private function onConfig(_) {
        var colorCalcId:String = _colorCalcSelector.selectedItem.colorCalcId;
        var dialog:ColorCalculatorConfigDialog = null;
        switch (colorCalcId) {
            case "range":
                dialog = new RangeColorCalculatorConfigDialog();
        }

        if (dialog != null) {
            dialog.colorCalcParams = _colorCalcParams;
            dialog.onDialogClosed = function(e) {
                if (e.button == DialogButton.APPLY) {
                    _colorCalcParams = dialog.colorCalcParams;
                    var event = new UIEvent(UIEvent.CHANGE);
                    dispatch(event);
                }
            };
            dialog.show();
        }
    }
}