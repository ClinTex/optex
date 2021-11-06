package core.dashboards.portlets;

import core.graphs.BarGraph;

class BarGraphPortletInstance extends PortletInstance {
    private var _bar:BarGraph;

    public function new() {
        super();

        _bar = new BarGraph();
        _bar.percentWidth = 100;
        _bar.percentHeight = 100;
        _bar.createRandomData();
        addComponent(_bar);
    }

    public override function refresh() {
        _bar.createRandomData();
    }
}