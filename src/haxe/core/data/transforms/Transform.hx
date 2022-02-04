package core.data.transforms;

class Transform implements ITransform {
    public function new() {
    }

    public function applyTransform(table:GenericTable, details:TransformDetails, context:Map<String, Any>):GenericTable {
        return table;
    }
}