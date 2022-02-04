package core.data.transforms;

class SetField extends Transform {
    public override function applyTransform(table:GenericTable, details:TransformDetails, context:Map<String, Any>):GenericTable {
        var fieldName = Std.string(details.transformParameters[0]);
        var fieldValue = details.transformParameters[1];
        var fieldIndex = table.getFieldIndex(fieldName);
        
        for (record in table.records) {
            record.data[fieldIndex] = fieldValue;
        }

        return table;
    }
}