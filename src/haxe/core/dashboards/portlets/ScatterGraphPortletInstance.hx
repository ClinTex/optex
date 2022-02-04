package core.dashboards.portlets;

import core.data.GenericTable;
import core.graphs.ScatterGraph;
import core.graphs.ColorCalculator;
import core.graphs.MarkerFunctions;

using StringTools;

class ScatterGraphPortletInstance extends PortletInstance {
    private var _scatter:ScatterGraph;

    public function new() {
        super();

        _scatter = new ScatterGraph();
        _scatter.percentWidth = 100;
        _scatter.percentHeight = 100;
        //_scatter.labelRotation = -45;
        //_bar.sort = null;

        _scatter.registerEvent(ScatterGraphEvent.POINT_SELECTED, onPointSelected);
        _scatter.registerEvent(ScatterGraphEvent.POINT_UNSELECTED, onPointUnselected);

        addComponent(_scatter);
    }

    private function onPointSelected(e:ScatterGraphEvent) {
        var axisX = config("axisX");
        var value = e.data.originalX;
        dashboardInstance.addFilterItem(axisX, value);
    }

    private function onPointUnselected(e:ScatterGraphEvent) {
        var axisX = config("axisX");
        dashboardInstance.removeFilterItem(axisX);
    }

    public override function onFilterChanged(filter:Map<String, Any>) {
        var axisX = config("axisX");
        var value = filter.get(axisX);
        if (value == null) {
            _scatter.unselectPoints();
            return;
        }
        _scatter.selectPointFromData(value);
    }

    private var _table:GenericTable = null;
    public override function onDataRefreshed(table:GenericTable) {
        _table = table;

        var axisX = config("axisX");
        var axisY = config("axisY");
        var size = config("size");
        var records = table.records;
        records.sort(function(o1, o2) {
            if (Std.string(o1.getFieldValue(axisX)) < Std.string(o2.getFieldValue(axisX))) {
                return -1;
            }
            if (Std.string(o1.getFieldValue(axisX)) > Std.string(o2.getFieldValue(axisX))) {
                return 1;
            }
            return 0;
        });

        _scatter.getMarkerValueY = MarkerFunctions.get(config("markerFunction"));
        _scatter.markerBehind = configBool("markerBehind");

        var graphData:Dynamic = [];
        var axisYParts = axisY.split(",");
        for (part in axisYParts) {
            part = part.trim();
            if (part.length == 0) {
                continue;
            }

            var fieldIndexY = table.getFieldIndex(part);
            var values:Array<Dynamic> = [];
            var n = 0;
            for (row in records) {
                var valueX = row.getFieldValue(axisX);
                var valueY = Std.parseFloat(row.getFieldValue(axisY));
                var valueSize = Std.parseFloat(row.getFieldValue(size));
                values.push({
                    x: valueX,
                    y: valueY,
                    size: valueSize * 30
                });

                n++;
            }

            graphData.push({
                key: part,
                values: values
            });
        }

        if (width > 0 && height > 0) {
            _scatter.data = graphData;
            onFilterChanged(dashboardInstance.filter);
        }
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