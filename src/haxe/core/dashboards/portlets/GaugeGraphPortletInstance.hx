package core.dashboards.portlets;

import core.graphs.GaugeGraph;
import core.data.GenericTable;

class GaugeGraphPortletInstance extends PortletInstance {
    private var _gauge:GaugeGraph;

    public function new() {
        super();

        _gauge = new GaugeGraph();
        _gauge.horizontalAlign = "center";
        _gauge.width = 300;
        _gauge.height = 150;

        addComponent(_gauge);
    }

    private var _table:GenericTable = null;
    public override function onDataRefreshed(table:GenericTable) {
        _table = table;

        var valueField = config("value");
        var value = Std.parseFloat(table.records[0].getFieldValue(valueField));

        var userInput1:Null<Float> = dashboardInstance.filter.get("Predicted Expected Number of Visits");
        if (userInput1 == null) {
            userInput1 = 0;
        }
        var userInput2:Null<Float> = dashboardInstance.filter.get("Predicted Actual Number of Visits");
        if (userInput2 == null) {
            userInput2 = 0;
        }
        var userInput3:Null<Float> = dashboardInstance.filter.get("Predicted Number Completed Visits");
        if (userInput3 == null) {
            userInput3 = 0;
        }

        value *= userInput1;
        value *= userInput2;
        value *= userInput3;
        value /= 1000;
        trace(Std.parseFloat(table.records[0].getFieldValue(valueField)), userInput1, userInput2, userInput3, value);
        _gauge.setValue(value);
    }

    private var hasSize:Bool = false;
    private override function validateComponentLayout():Bool {
        var b = super.validateComponentLayout();
        if (width > 0 && height > 0) {
            if (hasSize == false) {
                hasSize = true;
                if (_table != null) {
                    onDataRefreshed(_table);
                }
            }
        }
        return b;
    }
}