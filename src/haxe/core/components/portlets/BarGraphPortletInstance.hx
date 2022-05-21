package core.components.portlets;

import core.data.DataSourceData;
import haxe.ui.components.Label;
import core.graphs.BarGraph;
import core.data.InternalDB;
import core.graphs.ColorCalculator_OLD;
import core.graphs.MarkerFunctions;
import haxe.ui.events.UIEvent;
import core.data.PortletInstancePortletData;
import js.lib.Promise;
import core.util.color.ColorCalculatorFactory;

using StringTools;

class BarGraphPortletInstance extends PortletInstance {
    private var _bar:BarGraph = null;

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

        if (_bar == null) {
            _bar = new BarGraph();
            _bar.percentWidth = 100;
            _bar.percentHeight = 100;
            _bar.labelRotation = -45;

            _bar.registerEvent(BarGraphEvent.BAR_SELECTED, onBarSelected);
            _bar.registerEvent(BarGraphEvent.BAR_UNSELECTED, onBarUnselected);

            addComponent(_bar);
        }
    }

    public override function autoConfigure():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            if (instanceData == null) {
                instanceData = new PortletInstancePortletData();
            }
            if (instanceData.dataSourceId == null) {
                if (InternalDB.dataSources.data.length > 0) {
                    var firstDataSource = InternalDB.dataSources.data[0];
                    PortletDataUtils.fetchTableData(firstDataSource.databaseName, firstDataSource.tableName).then(function(r) {
                        var firstField = r.info.fieldDefinitions[0];
                        var secondField = r.info.fieldDefinitions[1];
                        instanceData.dataSourceId = firstDataSource.dataSourceId;
                        instanceData.setValue("axisX", firstField.fieldName);
                        instanceData.setValue("axisY", secondField.fieldName);
                        resolve(true);
                    });
                } else {
                    resolve(true);
                }
            } else {
                resolve(true);
            }
        });
    }

    public override function refreshView() {
        super.refreshView();

        if (_dataSourceData == null) {
            return;
        }

        page.getTableData(this).then(function(table) {
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

            _bar.colourCalculator = ColorCalculatorFactory.getColorCalculator(_colorCalculator);
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

            if (width > 0 && height > 0) {
                _bar.data = graphData;
            }
        });
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

    private override function onReady() {
        super.onReady();

        if (portletData.dataSourceId != null) {
            datasourceSelector.selectedDataSource = InternalDB.dataSources.utils.dataSource(portletData.dataSourceId);
            axisXSelector.selectedDataSource = datasourceSelector.selectedDataSource;
            axisYSelector.selectedDataSource = datasourceSelector.selectedDataSource;
        }

        if (portletData.dataSourceId != null) {
            if (portletData.transform != null) {
                transformBuilder.selectedDataSource = InternalDB.dataSources.utils.dataSource(portletData.dataSourceId);
                transformBuilder.transformString = portletData.transform;
            }

            if (portletData.getStringValue("axisX") != null) {
                axisXSelector.selectedFieldName = portletData.getStringValue("axisX");
                axisXSelector.transformString = portletData.transform;
            }

            if (portletData.getStringValue("axisY") != null) {
                axisYSelector.selectedFieldName = portletData.getStringValue("axisY");
                axisYSelector.transformString = portletData.transform;
            }

            if (portletData.getStringValue("markerFunction") != null) {
                markerFunctionSelector.markerString = portletData.getStringValue("markerFunction");
                markerFunctionSelector.markerBehind = portletData.getBoolValue("markerBehind");
            }

            if (portletData.getStringValue("colorCalculator") != null) {
                colorCalculatorSelector.colorCalcString = portletData.getStringValue("colorCalculator");
            }
        } else {
            onDataSourceSelected(null);
        }
    }

    @:bind(datasourceSelector, UIEvent.CHANGE)
    private function onDataSourceSelected(_) {
        transformBuilder.selectedDataSource = datasourceSelector.selectedDataSource;
        portletData.dataSourceId = datasourceSelector.selectedDataSource.dataSourceId;
        axisXSelector.selectedDataSource = datasourceSelector.selectedDataSource;
        axisYSelector.selectedDataSource = datasourceSelector.selectedDataSource;
        dispatchPortletConfigChanged();
    }

    @:bind(transformBuilder, UIEvent.CHANGE)
    private function onTransformBuilderChange(_) {
        portletData.transform = transformBuilder.transformString;
        axisXSelector.transformString = portletData.transform;
        axisYSelector.transformString = portletData.transform;
        dispatchPortletConfigChanged();
    }

    @:bind(axisXSelector, UIEvent.CHANGE)
    private function onAxisXChange(_) {
        if (axisXSelector.selectedFieldName != null) {
            portletData.setValue("axisX", axisXSelector.selectedFieldName);
            dispatchPortletConfigChanged();
        }
    }

    @:bind(axisYSelector, UIEvent.CHANGE)
    private function onAxisYChange(_) {
        if (axisYSelector.selectedFieldName != null) {
            portletData.setValue("axisY", axisYSelector.selectedFieldName);
            dispatchPortletConfigChanged();
        }
    }

    @:bind(markerFunctionSelector, UIEvent.CHANGE)
    private function onMarkerFunctionChange(_) {
        if (markerFunctionSelector.markerString != null) {
            portletData.setValue("markerFunction", markerFunctionSelector.markerString);
            portletData.setValue("markerBehind", markerFunctionSelector.markerBehind);
            dispatchPortletConfigChanged();
        }
    }

    @:bind(colorCalculatorSelector, UIEvent.CHANGE)
    private function onColorCalcChange(_) {
        if (colorCalculatorSelector.colorCalcString != null) {
            portletData.setValue("colorCalculator", colorCalculatorSelector.colorCalcString);
            dispatchPortletConfigChanged();
        } else {
            portletData.removeValue("colorCalculator");
            dispatchPortletConfigChanged();
        }
    }
}