package core.data.transforms;

using StringTools;

class FilterBy extends Transform {
    public override function applyTransform(table:GenericTable, details:TransformDetails, context:Map<String, Any>):GenericTable {
        var fieldName = Std.string(details.transformParameters[0]);
        var fieldValue = details.transformParameters[1];
        if (fieldName.startsWith("$")) {
            fieldName = fieldName.substring(1);
            fieldValue = context.get(fieldName);
        }

        if (fieldValue == null) {
            return table;
        }

        var fieldIndex = table.getFieldIndex(fieldName);

        var result = table.clone();
        for (record in table.records) {
            var existingData = record.data;
            if (existingData[fieldIndex] == fieldValue) {
                var recordCopy = new GenericData();
                recordCopy.fromArray(existingData.copy());
                result.records.push(recordCopy);
            }
        }

        return result;
    }
}