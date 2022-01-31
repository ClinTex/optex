package core.dashboards.portlets;

import core.data.GenericTable;
import core.graphs.ColorCalculator;
import core.graphs.BarGraph;
import core.graphs.MarkerFunctions;
import core.util.FunctionDetails;
import core.data.internal.CoreData.TableFragment;

using StringTools;

class BarGraphPortletInstance extends PortletInstance {
    private var _bar:BarGraph;

    public function new() {
        super();

        _bar = new BarGraph();
        _bar.percentWidth = 100;
        _bar.percentHeight = 100;
        _bar.labelRotation = -45;
        //_bar.sort = null;

        _bar.registerEvent(BarGraphEvent.BAR_SELECTED, onBarSelected);
        _bar.registerEvent(BarGraphEvent.BAR_UNSELECTED, onBarUnselected);

        addComponent(_bar);
    }

    private function onBarSelected(e:BarGraphEvent) {
        var axisX = config("axisX");
        var value = e.data.xValue;
        dashboardInstance.addFilterItem(axisX, value);
    }

    private function onBarUnselected(e:BarGraphEvent) {
        var axisX = config("axisX");
        dashboardInstance.removeFilterItem(axisX);
    }

    public override function onFilterChanged(filter:Map<String, Any>) {
        var axisX = config("axisX");
        var value = filter.get(axisX);
        if (value == null) {
            _bar.unselectBars();
            return;
        }
        _bar.selectBarFromData(value);
    }

    private function getColourCalculator():ColorCalculator {
        var s = config("colorCalculator");
        if (s == null || s.trim() == "") {
            return null;
        }

        var cc = null;
        var parts = s.split(":");
        var id = parts.shift();
        switch (id) {
            case "threshold":
                cc = new ThresholdBasedColourCalculator(Std.parseFloat(parts[0]));
        }

        return cc;
    }

    private var _table:GenericTable = null;
    public override function onDataRefreshed(table:GenericTable) {
        _table = table;

        var axisX = config("axisX");
        var axisY = config("axisY");
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

        _bar.colourCalculator = getColourCalculator();
        _bar.getMarkerValueY = MarkerFunctions.get(config("markerFunction"));
        _bar.markerBehind = configBool("markerBehind");

        var graphData:Dynamic = [];
        var axisYParts = axisY.split(",");
        for (part in axisYParts) {
            part = part.trim();
            if (part.length == 0) {
                continue;
            }

            var values:Array<Dynamic> = [];
            var n = 0;
            for (row in records) {
                var valueX = row.getFieldValue(axisX);
                var valueY = Std.parseFloat(row.getFieldValue(part));

                values.push({
                    x: valueX,
                    y: valueY
                });

                n++;
            }

            graphData.push({
                key: part,
                values: values
            });
        }

        if (width > 0 && height > 0) {
            _bar.data = graphData;
        }













        /*
        var graphData:Dynamic = [];
        var n = 0;
        for (row in fragment.data) {
            var valueX = row[fieldIndexX];
            var valueY = row[fieldIndexY];

            graphData.push({
                group: "" + n,
                value: Std.parseFloat(valueY)
            });

            n++;
        }

        if (width > 0 && height > 0) {
            _bar.data = graphData;
        }
        */
    }

    public override function refresh() {
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