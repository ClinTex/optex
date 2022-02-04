package core.data.transforms;

import core.data.internal.CoreData.FieldType;

class GroupBy extends Transform {
    public override function applyTransform(table:GenericTable, details:TransformDetails):GenericTable {
        var fieldName = details.transformParameters[0];
        var fieldIndex = table.getFieldIndex(fieldName);

        var result = new GenericTable();
        result.primaryKeyName = fieldName;
        result.info = {
            tableName: table.info.tableName,
            fieldDefinitions: table.info.fieldDefinitions.copy(),
            recordCount: 0
        }
        var map:Map<String, Array<Any>> = [];

        for (record in table.records) {
            var existingData = record.data;
            var uniqueFieldValue = existingData[fieldIndex];
            var newData = map.get(uniqueFieldValue);
            if (newData == null) {
                newData = existingData.copy();
                newData.push(1);
                map.set(uniqueFieldValue, newData);
            } else {
                var n = 0;
                for (d in existingData) {
                    if (n != fieldIndex && table.getFieldType(n) == FieldType.Number) {
                        if (fieldIndex < existingData.length) {
                            var existingValue = Std.parseFloat(existingData[n]);
                            var currentValue = Std.parseFloat(newData[n]);
                            var newValue = existingValue + currentValue;
                            newData[n] = newValue;
                        }
                    }
                    n++;
                }

                var lastIndex = existingData.length;
                var i:Int = newData[lastIndex];
                newData[lastIndex] = i + 1;
            }
        }

        result.defineField(fieldName + "Count", FieldType.Number);
        var n = 0;
        for (k in map.keys()) {
            var record = new GenericData();
            record.table = result;
            record.fromArray(map.get(k));
            result.records.push(record);
            n++;
        }
        result.info.recordCount = n;

        return result;
    }
}