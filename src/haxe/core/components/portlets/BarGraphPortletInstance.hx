package core.components.portlets;

import core.data.DataSourceData;
import haxe.ui.components.Label;
import core.graphs.BarGraph;
import core.data.InternalDB;
import core.graphs.ColorCalculator_OLD;
import core.graphs.MarkerFunctions;

using StringTools;

class BarGraphPortletInstance extends PortletInstance {
    private var _bar:BarGraph;

    private var _dataSourceData:DataSourceData = null;
    private var _transform:String;
    private var _axisX:String;
    private var _axisY:String;
    private var _markerFunction:String;
    private var _markerBehind:Bool;
    private var _colorCalculator:String;

    private var _init:Bool = false;
    public override function initPortlet() {
        if (_init == true) {
            //return;
        }

        super.initPortlet();
        _init = true;

        _dataSourceData = InternalDB.dataSources.utils.dataSource(instanceData.dataSourceId);
        _transform = getConfigValue("transform");
        _axisX = getConfigValue("axisX");
        _axisY = getConfigValue("axisY");
        _markerFunction = getConfigValue("markerFunction");
        _markerBehind = getConfigBoolValue("markerBehind");
        _colorCalculator = getConfigValue("colorCalculator");

        _bar = new BarGraph();
        _bar.percentWidth = 100;
        _bar.percentHeight = 100;
        _bar.labelRotation = -45;

        _bar.registerEvent(BarGraphEvent.BAR_SELECTED, onBarSelected);
        _bar.registerEvent(BarGraphEvent.BAR_UNSELECTED, onBarUnselected);

        addComponent(_bar);
    }

    public override function refreshView() {
        super.refreshView();
        trace("refreshing view");

        if (_dataSourceData == null) {
            trace("data source data is null");
            return;
        }

trace("doing refresh");

        page.getTableData(this).then(function(table) {
            trace("bar graph refresh view: " + table.records.length);

            var records = table.records;
            records.sort(function(o1, o2) {
                if (Std.string(o1.getFieldValue(_axisX)) < Std.string(o2.getFieldValue(_axisX))) {
                    return -1;
                }
                if (Std.string(o1.getFieldValue(_axisX)) > Std.string(o2.getFieldValue(_axisX))) {
                    return 1;
                }
                return 0;
            });

            _bar.colourCalculator = getColourCalculator();
            _bar.getMarkerValueY = MarkerFunctions.get(_markerFunction);
            _bar.markerBehind = _markerBehind;

            var graphData:Dynamic = [];
            var axisYParts = _axisY.split(",");
            for (part in axisYParts) {
                part = part.trim();
                if (part.length == 0) {
                    continue;
                }

                var values:Array<Dynamic> = [];
                var n = 0;
                for (row in records) {
                    var valueX = row.getFieldValue(_axisX);
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

            trace(width, height);
            if (width > 0 && height > 0) {
                _bar.data = graphData;
            }
        });
    }

    private function getColourCalculator():ColorCalculator_OLD {
        var s = _colorCalculator;
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

    private function onBarSelected(e:BarGraphEvent) {
    }

    private function onBarUnselected(e:BarGraphEvent) {
    }

    private var hasSize:Bool = false;
    private override function validateComponentLayout():Bool {
        var b = super.validateComponentLayout();
        if (width > 0 && height > 0) {
            if (hasSize == false) {
                hasSize = true;
                /*
                if (_table != null) {
                    onDataRefreshed(_table);
                }
                */
                refreshView();
            }
        }
        return b;
    }

    private override function get_configPage():PortletConfigPage {
        var configPage = new BarGraphConfigPage();
        return configPage;
    }
}

@:build(haxe.ui.ComponentBuilder.build("core/assets/ui/portlets/config-pages/bar-graph-config-page.xml"))
private class BarGraphConfigPage extends PortletConfigPage {
    public function new() {
        super();
    }
}