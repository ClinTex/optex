package core.dashboards.portlets;

import core.graphs.ScatterGraph;
import core.graphs.ColorCalculator;
import core.data.CoreData.TableFragment;
import core.data.Table;

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

        //_scatter.registerEvent(BarGraphEvent.BAR_SELECTED, onBarSelected);
        //_scatter.registerEvent(BarGraphEvent.BAR_UNSELECTED, onBarUnselected);

        addComponent(_scatter);
    }

    private var _fragment:TableFragment = null;
    public override function onDataRefreshed(fragment:TableFragment) {
        _fragment = fragment;

        var table = Table.fromFragment(fragment);
        var axisX = config("axisX");
        var axisY = config("axisY");
        var size = config("size");
        var fieldIndexX = table.getFieldIndex(axisX);
        var fieldIndexSize = table.getFieldIndex(size);
        var data = fragment.data;
        data.sort(function(o1, o2) {
            if (o1[fieldIndexX] < o2[fieldIndexX]) {
                return -1;
            }

            if (o1[fieldIndexX] > o2[fieldIndexX]) {
                return 1;
            }
            return 0;
        });

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
            for (row in data) {
                var valueX = row[fieldIndexX];
                var valueY = Std.parseFloat(row[fieldIndexY]);
                var valueSize = Std.parseFloat(row[fieldIndexSize]);
trace("value Size: " + valueSize);
                values.push({
                    x: valueX,
                    y: valueY,
                    size: valueSize
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
        }
    }

    private var hasSize:Bool = false;
    private override function validateComponentLayout():Bool {
        var b = super.validateComponentLayout();
        if (width > 0 && height > 0) {
            if (hasSize == false) {
                hasSize = true;
                if (_fragment != null) {
                    onDataRefreshed(_fragment);
                }
            }
        }
        return b;
    }
}