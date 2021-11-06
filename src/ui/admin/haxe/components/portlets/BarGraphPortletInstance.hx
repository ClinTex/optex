package components.portlets;

import graphs.BarGraph;

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
}