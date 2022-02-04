package core.data.transforms;

class Transform implements ITransform {
    public function new() {
    }

    public function applyTransform(table:GenericTable, details:TransformDetails):GenericTable {
        return table;
    }
}