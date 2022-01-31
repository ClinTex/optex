package core.dashboards;

import core.data.dao.IDataTable;
import core.data.DatabaseManager;
import core.data.GenericTable;
import core.data.GenericData;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.data.DataSource;
import haxe.ui.core.IDataComponent;
import core.dashboards.portlets.TableDataPortletInstance;
import core.dashboards.portlets.BarGraphPortletInstance;
import core.dashboards.portlets.ScatterGraphPortletInstance;
import core.dashboards.portlets.PortletInstance;
import haxe.ui.containers.VBox;
import haxe.ui.components.Label;
import core.data.dao.Database;

using StringTools;

class Portlet extends VBox implements IDataComponent {
    private var _instance:PortletInstance;

    private var _databaseName:String;
    private var _tableName:String;
    private var _transformId:String;
    private var _transformArgs:Map<String, String>;
    private var _additionalConfigParams:Map<String, String> = [];

    public function new() {
        super();

        addClass("card");
    }

    public function onFilterChanged(filter:Map<String, Any>) {
        if (_instance != null) {
            _instance.onFilterChanged(filter);
        }
    }

    public override function onReady() {
        super.onReady();

        if (_border == false) {
            addClass("no-border");
        }

        parseConfigData();
        _instance.additionalConfigParams = _additionalConfigParams;
        refreshData();

        if (_title != null) {
            var label = new Label();
            label.text = _title;
            label.id = "portletTitle";
            label.horizontalAlign = _titleAlign;
            label.addClass("card-title-label");
            label.addClass("portlet-title");
            label.addClass(_type + "-title");
            addComponent(label);
        }

        addComponent(_instance);
    }

    private var _database:Database = null;
    private var _table:IDataTable<GenericData> = null;
    private function refreshData() {
        DatabaseManager.instance.getDatabase(_databaseName).then(function(db) {
            _database = db;
            _table = _database.getTable(_tableName);
            _table.fetch({transformId: _transformId, transformParameters: _transformArgs}).then(function(data) {
                _instance.onDataRefreshed(cast _table);
            });
        });
    }

    private function parseConfigData() {
        for (i in 0..._dataSource.size) {
            var item = _dataSource.get(i);
            if (item.id == "source") {
                for (f in Reflect.fields(item)) {
                    switch (f) {
                        case "database":
                            _databaseName = Reflect.field(item, f);
                        case "table":
                            _tableName = Reflect.field(item, f);
                        case "transform":
                            var transform:String = Reflect.field(item, f);
                            transform = transform.trim();
                            var n = transform.indexOf("(");
                            if (n != null) {
                                var argsString = transform.substring(n + 1, transform.length - 1);
                                var transformArgs = [];
                                for (arg in argsString.split(",")) {
                                    arg = arg.trim();
                                    if (arg.length == 0) {
                                        continue;
                                    }
                                    if (arg.startsWith("'") && arg.endsWith("'")) {
                                        arg = arg.substr(1, arg.length - 2);
                                    }
                                    transformArgs.push(arg);
                                }

                                transform = transform.substr(0, n);
                                _transformArgs = [];
                                _transformArgs.set("fieldName", transformArgs[0]);
                            }
                            _transformId = transform;
                        case _:
                            _additionalConfigParams.set(f, Reflect.field(item, f));
                    }
                }
            }
        }
    }

    private var _title:String = null;
    public var title(get, set):String;
    private function get_title():String {
        return _title;
    }
    private function set_title(value:String):String {
        _title = value;
        return value;
    }

    private var _titleAlign:String = "center";
    public var titleAlign(get, set):String;
    private function get_titleAlign():String {
        return _titleAlign;
    }
    private function set_titleAlign(value:String):String {
        _titleAlign = value;
        return value;
    }

    private var _type:String;
    public var type(get, set):String;
    private function get_type():String {
        return _type;
    }
    private function set_type(value:String):String {
        if (value == _type) {
            return value;
        }

        _type = value;
        switch (_type) {
            case "chart-bar":
                _instance = new BarGraphPortletInstance();
                _instance.percentWidth = 100;
                _instance.percentHeight = 100;
            case "chart-scatter":
                _instance = new ScatterGraphPortletInstance();
                _instance.percentWidth = 100;
                _instance.percentHeight = 100;
            case "table":
                _instance = new TableDataPortletInstance();
                _instance.percentWidth = 100;
                _instance.percentHeight = 100;
        }

        return value;
    }

    private var _dataSource:DataSource<Dynamic> = new ArrayDataSource<Dynamic>();
    public var dataSource(get, set):DataSource<Dynamic>;
    private function get_dataSource():DataSource<Dynamic> {
        return _dataSource;
    }
    private function set_dataSource(value:DataSource<Dynamic>):DataSource<Dynamic> {
        _dataSource = value;
        return value;
    }

    private var _border:Bool = true;
    public var border(get, set):Bool;
    private function get_border():Bool {
        return _border;
    }
    private function set_border(value:Bool):Bool {
        if (value == _border) {
            return value;
        }

        _border = value;

        return value;
    }

    public function refresh() {
        if (_instance == null) {
            return;
        }

        _instance.refresh();
    }
}