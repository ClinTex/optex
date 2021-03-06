package core.data.transforms;

interface ITransform {
    function applyTransform(table:GenericTable, details:TransformDetails, context:Map<String, Any>):GenericTable;
}