package core.data;

import core.Types.TFieldDefinition;
import core.Types.TDataSource;
import js.lib.Promise;

@:enum
abstract FieldType(String) from String to String {
    var String = "string";
    var Boolean = "boolean";
    var Number = "number";
}

class DataSource {
    private var _dataSource:TDataSource = null;
    public function new(dataSource:TDataSource = null) {
        if (dataSource == null) {
            dataSource = {
                dataSourceName: null,
                fieldDefinitions: [],
                data: []
            }
        }
        _dataSource = dataSource;
    }

    public var name(get, set):String;
    private function get_name():String {
        return _dataSource.dataSourceName;
    }
    private function set_name(value:String):String {
        _dataSource.dataSourceName = value;
        return value;
    }

    public var rowCount(get, null):Int;
    private function get_rowCount():Int {
        return _dataSource.data.length;
    }

    public var fieldDefinitionCount(get, null):Int;
    private function get_fieldDefinitionCount():Int {
        return _dataSource.fieldDefinitions.length;
    }

    public var fieldDefinitions(get, null):Array<TFieldDefinition>;
    private function get_fieldDefinitions():Array<TFieldDefinition> {
        return _dataSource.fieldDefinitions;
    }

    public function defineField(name:String, type:FieldType) {
        var tf:TFieldDefinition = {
            fieldName: name,
            fieldType: type
        }
        _dataSource.fieldDefinitions.push(tf);
    }

    public function rows():Array<Row> {
        var r = [];

        for (d in _dataSource.data) {
            r.push(new Row(this, d));
        }

        return r;
    }

    public function row(index:Int):Row {
        var d = _dataSource.data[index];
        return new Row(this, d);
    }

    public function addRow(...values:Any) {
        var row:Array<Any> = [];
        for (v in values) {
            // TODO: validate it here
            row.push(Std.string(v));
        }
        _dataSource.data.push(row);
    }

    public function setData(data:Array<Array<Any>>) {
        _dataSource.data = data;
    }

    public function update():Promise<Dynamic> {
        return DataSourceManager.instance.updateDataSource(this);
    }

    public function commit():Promise<Dynamic> {
        return update();
    }

    public var raw(get, null):TDataSource;
    private function get_raw():TDataSource {
        return _dataSource;
    }

    public function fieldNameToIndex(name:String):Null<Int> {
        var n = 0;
        for (f in _dataSource.fieldDefinitions) {
            if (f.fieldName == name) {
                return n;
            }
            n++;
        }
        return null;
    }

    public function convertValue(value:String, fieldDefinitionIndex:Int):Any {
        var fd = _dataSource.fieldDefinitions[fieldDefinitionIndex];

        var convertedValue:Any = value;
        if (fd.fieldType == FieldType.Number) {
            convertedValue = Std.parseFloat(value);
        } else if (fd.fieldType == FieldType.Boolean) {
            convertedValue = (value == "true");
        }

        return convertedValue;
    }
}

class Row {
    private var _ds:DataSource = null;
    private var _data:Array<Any> = null;

    public function new(ds:DataSource, data:Array<Any>) {
        _ds = ds;
        _data = data;
    }

    public function value(name:Null<String> = null, index:Null<Int> = null, value:Any = null):Dynamic {
        if (name != null) {
            index = _ds.fieldNameToIndex(name);
        }
        var v = _ds.convertValue(_data[index], index);
        if (value != null) {
            _data[index] = Std.string(value);
        }
        return v;
    }
}