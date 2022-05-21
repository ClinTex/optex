package core.components.portlets;

import core.data.DataSourceData;
import core.graphs.LineGraph;
import core.data.InternalDB;
import core.graphs.MarkerFunctions;
import haxe.ui.events.UIEvent;
import core.data.PortletInstancePortletData;
import js.lib.Promise;
import core.util.color.ColorCalculatorFactory;

class LineGraphPortletInstance extends PortletInstance {
    private var _graph:LineGraph = null;

    private var _dataSourceData:DataSourceData = null;
    private var _transform:String;
    private var _axisX:String;
    private var _axisY:String;
    private var _colorCalculator:String;

    private override function onReady() {
        super.onReady();
    }

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
        _colorCalculator = getConfigValue("colorCalculator");

        if (_graph == null) {
            _graph = new LineGraph();
            _graph.percentWidth = 100;
            _graph.percentHeight = 100;

            addComponent(_graph);
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
            if (width > 0 && height > 0) {
                _graph.data = buildRandomLineData();
            }
        });
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

    private function buildRandomLineData():Dynamic {
        var n = 100;
        var data = [];
        
        var values1 = [];
        var lastValue:Null<Int> = null;
        for (i in 0...n) {
            var v = getRandomInt(0, 100);
            if (lastValue != null) {
                v = lastValue + getRandomInt(-10, 10);
            }
            values1.push({x:i, y: v});
            lastValue = v;
        }
        
        var values2 = [];
        var lastValue:Null<Int> = null;
        for (i in 0...n) {
            var v = getRandomInt(0, 100);
            if (lastValue != null) {
                v = lastValue + getRandomInt(-10, 10);
            }
            values2.push({x:i, y: v});
            lastValue = v;
        }
        
        var values3 = [];
        var lastValue:Null<Int> = null;
        for (i in 0...n) {
            var v = getRandomInt(0, 100);
            if (lastValue != null) {
                v = lastValue + getRandomInt(-10, 10);
            }
            values3.push({x:i, y: v});
            lastValue = v;
        }
         
        var values4 = [];
        var lastValue:Null<Int> = null;
        for (i in 0...n) {
            var v = getRandomInt(0, 100);
            if (lastValue != null) {
                v = lastValue + getRandomInt(-10, 10);
            }
            values4.push({x:i, y: v});
            lastValue = v;
        }
        
        data.push({
            key: "Series 1",
            values: values1
        });
        data.push({
            key: "Series 2",
            values: values2
        });
        data.push({
            key: "Series 3",
            values: values3
        });
        data.push({
            key: "Series 4",
            values: values4
        });
        
        return data;
    }

    private function getRandomInt(min, max) {
        return Math.floor(Math.random() * (max - min) ) + min;
    }
}