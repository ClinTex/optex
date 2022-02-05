package core.dashboards.portlets;

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
        box.addComponent(_valueLabel);

        addComponent(box);
    }

    public override function clearData() {
        _valueLabel.text = "-";
    }

    private override function onConfigChanged() {
        _promptLabel.text = config("prompt");
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
    }
}
