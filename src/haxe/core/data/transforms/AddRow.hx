package core.data.transforms;

import core.data.internal.CoreData.FieldType;

using StringTools;

class AddRow extends Transform {
    public override function applyTransform(table:GenericTable, details:TransformDetails, context:Map<String, Any>):GenericTable {
        var primaryKeyValue = Std.string(details.transformParameters[0]);
        var fieldName = Std.string(details.transformParameters[1]);
        var fieldValue = details.transformParameters[2];
        if (Std.string(fieldValue).startsWith("$")) {
            fieldValue = context.get(Std.string(fieldValue).substring(1));
        }
        var fieldIndex = table.getFieldIndex(fieldName);

        var data:Array<Any> = [];
        for (fd in table.info.fieldDefinitions) {
            switch (fd.fieldType) {
                case FieldType.String:
                    data.push("");
                case FieldType.Boolean:
                    data.push(false);
                case FieldType.Number:
                    data.push(0);
                case _:
                    data.push(null);
            }
        }

        var primaryKeyIndex = table.getFieldIndex(table.primaryKeyName);
        data[primaryKeyIndex] = primaryKeyValue;
        data[fieldIndex] = fieldValue;
        table.createRecord().fromArray(data);

        return table;
    }
}