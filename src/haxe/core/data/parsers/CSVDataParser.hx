package core.data.parsers;

import core.data.CoreData.FieldType;
import core.data.CoreData.TableFieldInfo;
using StringTools;

class CSVDataParser extends DataParser {
    private var _data:Dynamic;
    private var _firstLine:String = null;
    private var _lines:Array<String> = [];
    public function new() {
        super();
    }

    public override function getFieldDefinitions():Array<TableFieldInfo> {
        var fds = [];
        var parts = _firstLine.split(",");
        for (p in parts) {
            p = p.trim();
            if (p.startsWith("\"") && p.endsWith("\"")) {
                p = p.substring(1, p.length - 1);
            }
            if (p.startsWith("'") && p.endsWith("'")) {
                p = p.substring(1, p.length - 1);
            }
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
                if (p.startsWith("\"") && p.endsWith("\"")) {
                    p = p.substring(1, p.length - 1);
                }
                if (p.startsWith("'") && p.endsWith("'")) {
                    p = p.substring(1, p.length - 1);
                }
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
