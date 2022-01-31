package core.data.parsers;

import core.data.internal.CoreData.FieldType;
import core.data.internal.CoreData.TableFieldInfo;
using StringTools;

class CSVDataParser extends DataParser {
    private var _data:Dynamic;
    private var _firstLine:String = null;
    private var _lines:Array<String> = [];

    private var _fieldDefs:Array<TableFieldInfo> = null;
    private var _parsedData:Array<Array<Any>> = null;

    public function new() {
        super();
    }

    public override function getFieldDefinitions():Array<TableFieldInfo> {
        if (_fieldDefs != null) {
            return _fieldDefs;
        }

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

        _fieldDefs = fds;
        return fds;
    }

    public override function getData():Array<Array<Any>> {
        if (_parsedData != null) {
            return _parsedData;
        }

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

        _parsedData = d;
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

        guessFieldTypes();
    }

    private function guessFieldTypes() {
        var fieldDefs = getFieldDefinitions();
        var parsedData = getData();

        var boolFields:Map<String, Bool> = [];
        var numberFields:Map<String, Bool> = [];
        for (row in parsedData) {
            var fieldIndex = 0;
            for (fieldValue in row) {

                var fieldName = fieldDefs[fieldIndex].fieldName;
                var isBool = Std.string(fieldValue ) == "true" || Std.string(fieldValue ) == "false" || Std.string(fieldValue ) == "yes" || Std.string(fieldValue ) == "no";
                var isNumber = !Math.isNaN(Std.parseFloat(fieldValue));

                if (boolFields.exists(fieldName) == false) {
                    boolFields.set(fieldName, isBool);
                } else {
                    var existing = boolFields.get(fieldName);
                    boolFields.set(fieldName, existing && isBool);
                }

                if (numberFields.exists(fieldName) == false) {
                    numberFields.set(fieldName, isNumber);
                } else {
                    var existing = numberFields.get(fieldName);
                    numberFields.set(fieldName, existing && isNumber);
                }

                fieldIndex++;
            }
        }

        for (fd in fieldDefs) {
            fd.fieldType = FieldType.String;

            if (boolFields.get(fd.fieldName) == true) {
                fd.fieldType = FieldType.Boolean;
            }
            if (numberFields.get(fd.fieldName) == true) {
                fd.fieldType = FieldType.Number;
            }
        }
    }
}
