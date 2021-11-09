package core.dashboards.portlets;

import core.graphs.BarGraph;
import core.data.CoreData.TableFragment;
import core.data.Table;

class BarGraphPortletInstance extends PortletInstance {
    private var _bar:BarGraph;

    public function new() {
        super();

        _bar = new BarGraph();
        _bar.percentWidth = 100;
        _bar.percentHeight = 100;
        _bar.sort = null;
        addComponent(_bar);
    }

    private var _fragment:TableFragment = null;
    public override function onDataRefreshed(fragment:TableFragment) {
        _fragment = fragment;

        var table = Table.fromFragment(fragment);
        var axisX = config("axisX");
        var axisY = config("axisY");
        var fieldIndexX = table.getFieldIndex(axisX);
        var fieldIndexY = table.getFieldIndex(axisY);

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
    }

    public override function refresh() {
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