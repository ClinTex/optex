package core.data.parsers;

import core.data.DataSource.FieldType;
import core.Types.TFieldDefinition;

using StringTools;

class CSVDataParser extends DataParser {
    private var _data:Dynamic;
    private var _firstLine:String = null;
    private var _lines:Array<String> = [];
    public function new() {
        super();
    }

    public override function getFieldDefinitions():Array<TFieldDefinition> {
        var fds = [];
        var parts = _firstLine.split(",");
        for (p in parts) {
            p = p.trim();
            fds.push({
                fieldName: p,
                fieldType: FieldType.String
            });
        }
        return fds;
    }

    public override function getData():Array<Array<Any>> {
        var d = [];

        for (l in _lines) {
            var parts = l.split(",");
            var row = [];
            for (p in parts) {
                p = p.trim();
                row.push(p);
            }
            d.push(row);
        }

        return d;
    }

    public override function parse(data:Dynamic) {
        _data = data;

        var s = Std.string(_data);

        var lines = s.split("\n");
        _lines = [];
        for (line in lines) {
            line = line.trim();
            if (line.length == 0) {
                continue;
            }

            if (_firstLine == null) {
                _firstLine = line;
            } else {
                _lines.push(line);
            }
        }
    }
}
