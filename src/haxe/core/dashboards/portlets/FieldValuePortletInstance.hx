package core.dashboards.portlets;

import haxe.ui.util.Color;
import core.util.color.IColorCalculator;
import core.util.color.ColorCalculatorFactory;
import core.util.FunctionDetails;
import haxe.ui.util.MathUtil;
import core.data.internal.CoreData.FieldType;
import haxe.ui.components.Label;
import haxe.ui.layouts.VerticalLayout;
import haxe.ui.containers.VBox;
import core.data.GenericTable;

class FieldValuePortletInstance extends PortletInstance {
    private var _promptLabel:Label;
    private var _valueLabel:Label;

    public function new() {
        super();
        horizontalAlign = "center";

        var box = new VBox();

        _promptLabel = new Label();
        _promptLabel.horizontalAlign = "center";
        _promptLabel.text = "Enter value:";
        box.addComponent(_promptLabel);

        _valueLabel = new Label();
        _valueLabel.text = "-";
        _valueLabel.horizontalAlign = "center";
        _valueLabel.customStyle.opacity = .7;
        box.addComponent(_valueLabel);

        addComponent(box);
    }

    public override function clearData() {
        _valueLabel.text = "-";
        _valueLabel.customStyle.color = null;
        _valueLabel.invalidateComponentStyle();
}

    private var _colorCalculator:IColorCalculator = null;
    private override function onConfigChanged() {
        _promptLabel.text = config("prompt");

        var promptFontSize = configFloat("promptFontSize", -1);
        if (promptFontSize > 0) {
            _promptLabel.customStyle.fontSize = promptFontSize;
            _promptLabel.invalidateComponentStyle();
        }

        var valueFontSize = configFloat("valueFontSize", -1);
        if (valueFontSize > 0) {
            _valueLabel.customStyle.fontSize = valueFontSize;
            _valueLabel.invalidateComponentStyle();
        }

        var colorCalculator = config("colorCalculator");
        if (colorCalculator != null) {
            trace("------------------> " + colorCalculator);
            var details = new FunctionDetails(colorCalculator);
            _colorCalculator = ColorCalculatorFactory.getColorCalculator(details.name);
            _colorCalculator.configure(details.params);
            trace(details.name);
            trace(details.params);
        }
    }

    private function applyColor() {
        if (_colorCalculator == null) {
            return;
        }

        var data = Std.parseFloat(_valueLabel.text);
        var col = _colorCalculator.getColor(data);
        if (col != null) {
            _valueLabel.customStyle.color = Color.fromString(col);
            _valueLabel.invalidateComponentStyle();
        }
    }

    public override function onDataRefreshed(table:GenericTable) {
        var fieldType = table.getFieldType(table.getFieldIndex(config("fieldName")));

        var value:Any = table.records[0].getFieldValue(config("fieldName"));
        switch (fieldType) {
            case FieldType.Number:
                value = MathUtil.round(value, 2);
            case _:
        }
        _valueLabel.text = Std.string(value);
        applyColor();
    }
}
