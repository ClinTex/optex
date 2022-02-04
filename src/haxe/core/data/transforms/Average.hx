package core.data.transforms;

class Average extends Transform {
    public override function applyTransform(table:GenericTable, details:TransformDetails):GenericTable {
        if (details.transformParameters.length == 1 && table.primaryKeyName != null) {
            details.transformParameters.insert(0, table.primaryKeyName);
        }
        var divisorField = details.transformParameters[0];
        var resultField = details.transformParameters[1];

        var divisorFieldIndex = table.getFieldIndex(divisorField);
        if (table.getFieldIndex(divisorField + "Count") != -1) {
            divisorFieldIndex = table.getFieldIndex(divisorField + "Count");
        }

        var resultFieldIndex = table.getFieldIndex(resultField);

        for (record in table.records) {
            var n:Float = record.getFieldValueByIndex(resultFieldIndex);
            var d :Float= record.getFieldValueByIndex(divisorFieldIndex);
            var r:Float = n / d;
            record.data[resultFieldIndex] = Std.string(r);
        }

        return table;
    }
}