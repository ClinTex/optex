package core.components.dialogs.colors;

import haxe.ui.containers.dialogs.Dialog.DialogButton;
import haxe.ui.events.MouseEvent;

using StringTools;

@:build(haxe.ui.ComponentBuilder.build("core/assets/ui/dialogs/colors/range-color-calculator-config-dialog.xml"))
class RangeColorCalculatorConfigDialog extends ColorCalculatorConfigDialog {
    public function new() {
        super();
    }

    private override function onReady() {
        super.onReady();

        trace("ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ: ", _colorCalcParams);
        if (_colorCalcParams != null) {
            var n = Std.int(_colorCalcParams.length / 2);
            for (i in 0...n) {
                var condition = _colorCalcParams[i * 2 + 0];
                var selectedColor = Std.string(_colorCalcParams[i * 2 + 1]);
                trace("-----------------------> " + selectedColor);
                trace(condition, selectedColor);
                colorTable.dataSource.add({
                    condition: condition,
                    selectedColor: "#" + StringTools.hex(Std.parseInt(selectedColor), 6)
                });
            }
        }

        if (colorTable.dataSource.size == 0) {
            colorTable.dataSource.add({
                condition: "lt",
                selectedColor: "#ffffff"
            });
        }
    }

    @:bind(addItemButton, MouseEvent.CLICK)
    private function onAddItem(_) {
        colorTable.dataSource.add({
            condition: "lt",
            selectedColor: "#ffffff"
        });
    }

    private override function validateDialog(button:DialogButton, cb:Bool->Void) {
        if (button == DialogButton.APPLY) {
            _colorCalcParams = [];
            for (i in 0...colorTable.dataSource.size) {
                var item = colorTable.dataSource.get(i);
                _colorCalcParams.push(item.condition);
                _colorCalcParams.push(item.selectedColor);
            }
        }
        cb(true);
    }
}